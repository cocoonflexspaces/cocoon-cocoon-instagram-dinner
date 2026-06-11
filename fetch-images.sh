#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────
# fetch-images.sh — localize every remote image in the Instagram deck
# (cocoonflexspaces.com listings + Google Drive thumbnails), then
# rewrite index.html to point at the local copies.
#
# Run once from this folder on your Mac:
#   bash fetch-images.sh
#
# Safe to re-run: already-valid downloads are skipped, and the HTML
# rewrite only swaps URLs whose local file downloaded successfully.
# A backup is kept at index.html.bak (first run only).
#
# If any DRIVE file fails: the folder isn't link-shared. Either flip
# the folder to "Anyone with the link → Viewer" and re-run, or
# download the photo manually from Drive and save it to the exact
# local path printed in the failure line — then re-run.
# ─────────────────────────────────────────────────────────────────────

set -uo pipefail
cd "$(dirname "$0")"

mkdir -p img/joy img/elliot img/brutal img/halloway img/skylight img/fountain img/lazarus img/stagehouse img/tower img/skyline img/skyline-pool img/bankhall img/luz img/raisfeld/nyc195 img/raisfeld/nyc293 img/raisfeld/nyc323 img/raisfeld/nyc327 img/raisfeld/nyc315 img/raisfeld/nyc322 img/raisfeld/bk410 img/raisfeld/bk437 img/raisfeld/bk166 img/maxima img/victoria img/ld/2044 img/ld/2060 img/ld/2253 img/ld/2593 img/ld/3333 img/ld/2580 img/ld/2223 img/ld/9005 img/ld/2244 img/ld/2136 img/ld/2490 img/ld/2132 img/ld/2267

UA='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Safari/605.1.15'
COOKIE_JAR="$(mktemp)"
MANIFEST="$(mktemp)"
trap 'rm -f "$COOKIE_JAR" "$MANIFEST"' EXIT

valid_image() {
  [ -f "$1" ] && [ "$(stat -f%z "$1" 2>/dev/null || stat -c%s "$1")" -gt 1024 ] && \
    file "$1" | grep -qiE 'image|jpeg|png|webp'
}

dl() {
  local url="$1" out="$2" referer="${3:-}"
  if valid_image "$out"; then
    echo "  ✓ $out (already downloaded)"
    printf '%s\t%s\n' "$url" "$out" >> "$MANIFEST"
    return
  fi
  echo "  → $out"
  curl -sSL --fail \
    -A "$UA" \
    ${referer:+-e "$referer"} \
    -H 'Accept: image/avif,image/webp,image/png,image/jpeg,*/*;q=0.8' \
    -H 'Accept-Language: en-US,en;q=0.9' \
    -b "$COOKIE_JAR" -c "$COOKIE_JAR" \
    -o "$out" "$url" \
    || { echo "    ✗ FAILED (http error): $url"; rm -f "$out"; return; }

  if valid_image "$out"; then
    printf '%s\t%s\n' "$url" "$out" >> "$MANIFEST"
  else
    echo "    ✗ FAILED (non-image response — WAF challenge or private Drive file)"
    echo "      Manual fix: download the image yourself and save it as: $out  → then re-run this script"
    rm -f "$out"
  fi
}

# Warm Sucuri cookies
echo "  → warming up cookies on cocoonflexspaces.com…"
curl -sSL -A "$UA" -b "$COOKIE_JAR" -c "$COOKIE_JAR" \
  -H 'Accept: text/html,application/xhtml+xml' \
  -o /dev/null "https://cocoonflexspaces.com/casa-joy/" || true

CJ="https://cocoonflexspaces.com/wp-content/uploads/2025/02"
CE="https://cocoonflexspaces.com/wp-content/uploads/2025/03"
CB9="https://cocoonflexspaces.com/wp-content/uploads/2025/09"
CB10="https://cocoonflexspaces.com/wp-content/uploads/2025/10"
CH="https://cocoonflexspaces.com/wp-content/uploads/2026/05"
DRV="https://drive.google.com/thumbnail?id="

echo "────────── Casa Joy ──────────"
R="https://cocoonflexspaces.com/casa-joy/"
dl "$CJ/cocoon-casa-joy-first-floor-dining-room-glass-table-fireplace-changelier.jpg" "img/joy/dining-chandelier.jpg" "$R"
dl "$CJ/cocoon-casa-joy-first-floor-staircase-large-basin.jpg"                        "img/joy/staircase-basin.jpg"  "$R"
dl "$CJ/cocoon-casa-joy-first-floor-lobby-area-fireplace.jpg"                         "img/joy/lobby-fireplace.jpg"  "$R"
dl "$CJ/cocoon-casa-joy-second-floor-entertainment-room-grand-piano-day-bed.jpg"      "img/joy/piano-room.jpg"       "$R"
dl "$CJ/cocoon-casa-joy-second-floor-library-room-couches-fireplace-wood-boards.jpg"  "img/joy/library.jpg"          "$R"
dl "$CJ/cocoon-casa-joy-fourth-floor-painting-studio.jpg"                             "img/joy/painting-studio.jpg"  "$R"
CJ7="https://cocoonflexspaces.com/wp-content/uploads/2025/07"
dl "$CJ7/cocoon-casa-joy-exterior-rose-garden-conversation-lounge-statues-1.jpg"      "img/joy/rose-garden.jpg"      "$R"
dl "$CJ7/cocoon-casa-joy-exterior-patio-white-steel-dining-table.jpg"                 "img/joy/patio.jpg"            "$R"

echo "────────── Casa Elliot ──────────"
R="https://cocoonflexspaces.com/casa-elliot/"
dl "$CE/cocoon-casa-elliott-living-room-fireplace-pier-mirror.jpg"                    "img/elliot/living-pier-mirror.jpg" "$R"
dl "$CE/cocoon-casa-elliott-wooden-staircase-upward-view-skylight.jpg"                "img/elliot/staircase-skylight.jpg" "$R"
dl "$CE/cocoon-casa-elliott-living-room-diagonal-view.jpg"                            "img/elliot/living-diagonal.jpg"    "$R"
dl "$CE/cocoon-casa-elliott-lounge-area-fireplace.jpg"                                "img/elliot/lounge-fireplace.jpg"   "$R"
dl "$CE/cocoon-casa-elliott-kitchen-large-marble-counters-front-view.jpg"             "img/elliot/kitchen-marble.jpg"     "$R"
dl "$CE/cocoon-casa-elliott-outdoor-backyard-large-table.jpg"                         "img/elliot/backyard-table.jpg"     "$R"
dl "$CE/cocoon-casa-elliott-living-room-couches-fireplace-large-mirror-front-view.jpg" "img/elliot/living-front.jpg"      "$R"
dl "$CE/cocoon-casa-elliott-exterior-building-facade-stoop.jpg"                       "img/elliot/facade-stoop.jpg"       "$R"

echo "────────── Casa Brutal ──────────"
R="https://cocoonflexspaces.com/casa-brutal/"
dl "$CB9/cocoon-casa-brutal-double-staircase-architectural-brutalist-horizontal-1.jpg" "img/brutal/staircase-horizontal.jpg" "$R"
dl "$CB9/cocoon-casa-brutal-exterior-brick-brutalist-facade-1.jpg"                     "img/brutal/facade.jpg"               "$R"
dl "$CB10/cocoon-casa-brutal-first-level-arts-center-white-walls-long-bar.jpg"         "img/brutal/long-bar.jpg"             "$R"
dl "$CB9/cocoon-casa-brutal-first-level-art-gallery-columns-white-walls.jpg"           "img/brutal/gallery-columns.jpg"      "$R"
dl "$CB9/cocoon-casa-brutal-lower-level-screening-room-projection-screen-1.jpg"        "img/brutal/screening-room.jpg"       "$R"
dl "$CB9/cocoon-casa-brutal-upper-level-gallery-white-walls-large-window-1-scaled.jpg" "img/brutal/upper-gallery.jpg"        "$R"
dl "$CB9/cocoon-casa-brutal-double-staircase-architectural-brutalist-vertical-1.jpg"   "img/brutal/staircase-vertical.jpg"   "$R"
dl "$CB9/cocoon-casa-brutal-street-level-sculpture-garden-conversation-1.jpg"          "img/brutal/sculpture-garden.jpg"     "$R"

echo "────────── Casa Halloway ──────────"
R="https://cocoonflexspaces.com/casa-halloway/"
dl "$CH/172-N-6th-St-1-1-scaled.jpg"                            "img/halloway/kitchen-dining.jpg"  "$R"
dl "$CH/2026-01-15-Bowerbird.-North-6th-st11984-copy-1.jpg"     "img/halloway/staircase.jpg"       "$R"
dl "$CH/2026-01-15-Bowerbird.-North-6th-st11967-copy-1.jpg"     "img/halloway/open-plan.jpg"       "$R"
dl "$CH/2026-01-15-Bowerbird.-North-6th-st12108-copy-2.jpg"     "img/halloway/living-room.jpg"     "$R"
dl "$CH/172-N-6th-St-8-1-1.jpg"                                 "img/halloway/backyard.jpg"        "$R"
dl "$CH/172-N-6th-St-14-1.jpg"                                  "img/halloway/roof-deck.jpg"       "$R"
dl "$CH/172-N-6th-St-3-1.jpg"                                   "img/halloway/second-living.jpg"   "$R"
dl "$CH/2026-01-15-Bowerbird.-North-6th-st12247-Copy-copy-1.jpg" "img/halloway/facade.jpg"         "$R"

echo "────────── The Skylight House (Drive) ──────────"
dl "${DRV}1H6M5ghS5_ho9_92LraVFwvqmei3NGvqI&sz=w1600" "img/skylight/01.jpg"
dl "${DRV}1xTXNuoMaLSzWoGF0-qLKulTM-FluXRgn&sz=w1600" "img/skylight/02.jpg"
dl "${DRV}1SypfEjchsXRrb1_Aun9ZdOg9XBKd3fly&sz=w1600" "img/skylight/03.jpg"
dl "${DRV}1mMdHsMyuhTym49tyO4wHgcZ11arw0cyJ&sz=w1600" "img/skylight/04.jpg"
dl "${DRV}1t-YeOv8XYPQV5ZLEBBzS62n7q0qcnorO&sz=w1600" "img/skylight/05.jpg"
dl "${DRV}1II1GNyJ9WzkpUzSlFyZ4IGPaQGI5u5FW&sz=w1600" "img/skylight/06.jpg"
dl "${DRV}1rwCGTAk5Xry7-PkZoYOzUw0Y-szbnGv6&sz=w1600" "img/skylight/07.jpg"
dl "${DRV}1xQRSeSeRk8En2dQtNZ3-Umj9PjePCFTr&sz=w1600" "img/skylight/08.jpg"
# extended candidates for the mosaic (curated visually after download)
dl "${DRV}1BlARpRMa9kAWmjvLheypGFCc5shhSMv9&sz=w1600" "img/skylight/09.jpg"
dl "${DRV}1rs_R15IEdMNbY6qI_QtmvjzdJJWV_A2u&sz=w1600" "img/skylight/10.jpg"
dl "${DRV}1SzBF9lxVaneN2_xLp1W-EMl6iq3uhYju&sz=w1600" "img/skylight/11.jpg"
dl "${DRV}1fbOCxbv7-0MATCf7FjTYupOBnvT4rAaN&sz=w1600" "img/skylight/12.jpg"
dl "${DRV}1LbfQAZrwJYHvIjnDMqjHMgY6fxqHyPE9&sz=w1600" "img/skylight/13.jpg"
dl "${DRV}1AbG4vO8oKtdGEkz3Fq-fom_v-USnubYb&sz=w1600" "img/skylight/14.jpg"
dl "${DRV}1Cz9XxXkrtgawZATxumgfkw050UIoFfCo&sz=w1600" "img/skylight/15.jpg"
dl "${DRV}1jYLJPMCj1Sr8CKr1Ijsw4ZhNptoBQKE7&sz=w1600" "img/skylight/16.jpg"

echo "────────── The Fountain Hall (Drive) ──────────"
dl "${DRV}1oCZszj5nRJo5Oe5YmuPC37w_m315yBE4&sz=w1600" "img/fountain/01.jpg"
dl "${DRV}1YoN8u7W1JCKbFPdiP37aiz7P4OUApp9r&sz=w1600" "img/fountain/02.jpg"
dl "${DRV}1Tf0YVldu410tTZLPlkU-Y6BjVqSGIP5t&sz=w1600" "img/fountain/03.jpg"
dl "${DRV}1YekghaTZRTI7Q2OVtB2jZgkcN9_DdR3I&sz=w1600" "img/fountain/04.jpg"
dl "${DRV}1gJFdympDFSkW1dVwSdwaAfxnOJdlhHtG&sz=w1600" "img/fountain/05.jpg"
dl "${DRV}1tk2ofzUYofVqfQAMs0smAGno7a8VnySz&sz=w1600" "img/fountain/06.jpg"
dl "${DRV}1OS1ll7W8MAy_PBqwvzBzuF4XHvyj_OBb&sz=w1600" "img/fountain/07.jpg"
dl "${DRV}13JvmLXr-qGNtJuU8LjmGLWrPtywrx0G4&sz=w1600" "img/fountain/08.jpg"

echo "────────── Casa Lazarus (Drive) ──────────"
dl "${DRV}1tXYk826dLrJIAY_ZZHYVE7MWFZR3HUIi&sz=w1600" "img/lazarus/01.jpg"
dl "${DRV}1QsTpXt8dt_7-wqT88K8a4jcSugHzV0pT&sz=w1600" "img/lazarus/02.jpg"
dl "${DRV}1EEST7pN32_2zityFZ2NgTbVdiizGpCLg&sz=w1600" "img/lazarus/03.jpg"
dl "${DRV}1j5yANvFg100dh2gaoquH74gYgWgoUK61&sz=w1600" "img/lazarus/04.jpg"
dl "${DRV}1XQxXHRv4L_PyhYwWNN8SyVO8OzKBRTQl&sz=w1600" "img/lazarus/05.jpg"
dl "${DRV}1x6nPorHew797ANda636MItk4_XrRGKAy&sz=w1600" "img/lazarus/06.jpg"
dl "${DRV}11e5nD-l2FCopyT1BNDSd7KYdQl_dRvWA&sz=w1600" "img/lazarus/07.jpg"
dl "${DRV}1MU8iCu4LD8yE5WvmA1ChW1YKmxSen3F0&sz=w1600" "img/lazarus/08.jpg"

echo "────────── Casa Sutton (Drive — now link-shared) ──────────"
dl "${DRV}1nMMalfWBGZQtHUJxh0N3O134SpGV0s0z&sz=w1600" "img/stagehouse/01.jpg"
dl "${DRV}1UTTU8tjGnWtNwcEarI5hV51Is-4x87Qn&sz=w1600" "img/stagehouse/02.jpg"
dl "${DRV}1OMuhzTTKI2mnZsZ_Z6ljoYKsbmRcv57k&sz=w1600" "img/stagehouse/03.jpg"
dl "${DRV}1DSChvOf4DUpsOjSm-jV1PjBAonJ8HbRp&sz=w1600" "img/stagehouse/04.jpg"
dl "${DRV}1C4JdekFoWFSYnqbkqy5qlOHWwoEci7Di&sz=w1600" "img/stagehouse/05.jpg"
dl "${DRV}1OQMfB5D8aD53FkNOXlqX4i_3gy9gbF4F&sz=w1600" "img/stagehouse/06.jpg"

echo "────────── The Eightieth Floor (Drive) ──────────"
dl "${DRV}15NbnBG3U_lWSQWqUkzewUzo-mNvXB-2r&sz=w1600" "img/tower/01.jpg"
dl "${DRV}1BpYoIV29z-Apf9NOwQL9NDE79lymB7V3&sz=w1600" "img/tower/02.jpg"
dl "${DRV}1OgkNRhQzS22kuXwDRCcjBHi5baw_Ts3j&sz=w1600" "img/tower/03.jpg"
dl "${DRV}1Ys8zLj5gLJgIDEK3H5H38lyNJ3rVML5P&sz=w1600" "img/tower/04.jpg"
dl "${DRV}13XiID-p2Ge53CEC4eyq-SkwW7E8Rk3sU&sz=w1600" "img/tower/05.jpg"
dl "${DRV}1UwIqAIqgQns7OUjAZ4g4uNUX2vOY3Y4C&sz=w1600" "img/tower/06.jpg"
dl "${DRV}1m1BfgP1-obOPK5XmScqyOiusvWgSl3PX&sz=w1600" "img/tower/07.jpg"
dl "${DRV}1mpXyYs8hSxwmM4l-_OacCop6oo_9zS3e&sz=w1600" "img/tower/08.jpg"

echo "────────── The Skyline Penthouse (Drive) ──────────"
dl "${DRV}1BoMdfU1Ij5Kr0KUJv23TbV-fTGC7Rl2M&sz=w1600" "img/skyline/01.jpg"
dl "${DRV}1fh6_NYTZ3A2_kT6lXwLJKGelaf3yDNgC&sz=w1600" "img/skyline/02.jpg"
dl "${DRV}1qlpceKD4Z-2oUwqsjRO0xsQgEV85GcOO&sz=w1600" "img/skyline/03.jpg"
dl "${DRV}1SuiOqhzAzCaCp8n4QmYcMHJHVSu-5puB&sz=w1600" "img/skyline/04.jpg"
dl "${DRV}1Nvu2oiBZuTj_ssWeT8H4F94Zw0JeAjcq&sz=w1600" "img/skyline/05.jpg"
dl "${DRV}139WdL_lqEPEaFiFiYYKFroRb3INHYJHS&sz=w1600" "img/skyline/06.jpg"
dl "${DRV}1kDDBOnrbetdYNysKEM8OKuc-3gBelPKI&sz=w1600" "img/skyline/07.jpg"
dl "${DRV}1Eal20AVHWX1CfDUt7CbXgTry8E8-0xt-&sz=w1600" "img/skyline/08.jpg"

echo "────────── The Skyline Penthouse — full pool (70, for visual curation) ──────────"
SKYPOOL_IDS=(
1fgIbHJPeZymyhfuyvdmz8Ajkbk2nSx5B 16X-Q82ErOIIl19hEydzSnAcb5vthXLSX 1PXUgo7tNTehPvHWdtYi7mzsOjWVLGy66
1IsSNBecnKszFKxz5IqfvhNPiyiyuPXfh 1U103HudLMoirECH2kfHkvtbRlzU_2S_l 1bxrz9xLKnJyVrSLr0-s8pKUQRjygPWHE
1fh6_NYTZ3A2_kT6lXwLJKGelaf3yDNgC 1ZN7epjHIJgON0nSB-Ufqfs0PtbotbvUV 1XZ13FUuxr1JyOcOXjzeoZzEBHLIg5A1C
15DMokTjbalNuEWDpnHt1qACPrllYb8D0 1QUB1preqbQDS-RkMIN5q12569YT1a48S 1NcJSEC83AjPbIASh_QFTbR3zyqK2qhe9
1djwdIYxh_hYuFa7U3HVGod3k8ulgSK3d 1qlpceKD4Z-2oUwqsjRO0xsQgEV85GcOO 1HmlY6ezGyIWg5GlqBau2HEzLAfeBniug
1BoMdfU1Ij5Kr0KUJv23TbV-fTGC7Rl2M 1w0x1lQlTnTVB8dZbxBRCLxu6q9VeseZE 11nsv3Ip4LL3QGrLT6A7NlLg36ZoakP02
1mGhRI-7m2rQjokEMZZsg-WQtt4Bjm1d6 16cm5A6qqLpIElI4We5e2i4TQ0ODX8w39 1qPDLt8H0OEl0pMN4yPI832UkzFnC866S
1GiPOepsM1gHRhwbL1Faazc-9uF6d0LlC 1-zkwzwOSeK0mVS0slG3qBCuBWj4Fh4Ff 1SuiOqhzAzCaCp8n4QmYcMHJHVSu-5puB
1Nvu2oiBZuTj_ssWeT8H4F94Zw0JeAjcq 139WdL_lqEPEaFiFiYYKFroRb3INHYJHS 1kDDBOnrbetdYNysKEM8OKuc-3gBelPKI
1YgFNonDEfy6o_19HAFUHrQp5zHvjJ_rd 1Ka76JlW9cz8m5l6DCl5U8rUggVIBlnbu 1Qc399obY-Tw0uR7j8qBB7d51mmREWFrA
1y8YtWq5RSa087OnDtZeGqlejcHVbzwsS 1rMiwYuM-dCZk1p9EKaPDb_qq2U1NqWl9 1SiCGSkj7E3ZVl0FqvO_rdp3Ao2yR02-1
1CnFtsJmkAbjOTu10Y80Sg93N4NFlNRAy 1XpI70ek7IzTXJJ4nEkDpq5Db1kvu_Vtz 1dLmVbNnCd98SL7lD1oL2VP20P7RHC6JG
10qlIQqtthvliMp1sLTtBWdiHnAD4uoV- 1Eal20AVHWX1CfDUt7CbXgTry8E8-0xt- 1fGw9kh-QlljWVUt_qBvAM9LhTcPp4haN
1jvYy4bmjmsCUwtsxBA8iR1WJcR5ZaRoH 1uYbnHB_p4hHUU49zD1JNESAset-PRTZh 1jsftD52Acshzg9OxmJ7XFOMoNZs1pe4L
1BT46gsGZVozsO1N55LXRYVTEarLEJbhr 1XfduO_QNKyym_TDAI5aiFYTVl2W6GzKs 1kZVbJLrUIuRg66qihrApAWjrhtYULX-r
18ewxH2-l8_bov8SCxRPWv6vtqLpDvEGD 1qIGUbqgh7f6ZCJjYXBr2i2y76dlDL4f6 1bQtzK37MtSO1VjfikeXqb-YRNS5f4mtp
1Iua4bY9kYrfkYSxMHY6u7v4TYiWSe-l5 16cIEBwAYgqHSP5lnOpYurCADUEpnr1QQ 1r-Riw7g0wsWh68ktWCfckS50_Od7dwh6
1JuGFQDEOdBbRjR1zCKHAu9ZjCBKqQ-_0 1uVRaDM8UoW-y6Co1oV7BsNNJRpxQ8ZV5 1feShkTNVkMh1BoIp3CfFI0tvPv1OfnUv
1Mw5W5S4dBO9KqVLRupyRZL78flNZLC0Z 1FqO7pltWJ5x2yHfBgPsLcE3OvlnE9mtb 14SuXDeKKudDZ9P6iVsrTXtOF_b0FpzD0
1lv74lpyZ3FVl07Eh3-knybhziccTDoEG 13V2zkiRboUzf9qZdceoAzUuwr8EqTzH3 18HyW3v3VRlP6au1jcKJAajpnRFDHCorq
1LQjEWS5ixYUV8zxyDcmsSro_ilxzj9Ql 14izj3l9Axewiv6zZHKnCNsN7flx7TPWS 14hp7HohWFsxwpbP5TOJ0Gtv9OGHbHBNs
1d4m5wRkuo9cGdYeKkglFvtE_uB_dS9PJ 1Z1zDNeuj8svnkbv595X1UKf9i-0HQZUb 1UCH6Pw5igG-pNJJv9b_1kDZwtzfSRJeK
1ZQO4F9IOT0vyH9KxDaiDiQrhDIXgFEgU 1OUUKPS01_W9vHXN7CGOUi5_8qGX80YPJ 1nii4UG9TkXdBR9zQiN2V8KVBy2FgiODt
1VPwqgyZBsKFPrJzbb_6HUDtdcAHR86mn
)
i=1
for id in "${SKYPOOL_IDS[@]}"; do
  dl "${DRV}${id}&sz=w1600" "img/skyline-pool/$(printf '%02d' $i).jpg"
  i=$((i+1))
done

echo "────────── The Banking Hall (Drive) ──────────"
dl "${DRV}1dSjgbeFtbgyy5q9OnCLh_PQaC5bKRfgv&sz=w1600" "img/bankhall/01.jpg"
dl "${DRV}1_wJjNnfykjJXOzh3TQeSHBnqmkq3WHqZ&sz=w1600" "img/bankhall/02.jpg"
dl "${DRV}1V0-p4MJdEfl6smr5P4tGsp6BtE-vuJMt&sz=w1600" "img/bankhall/03.jpg"
dl "${DRV}16pXaPDjffVy5jhIFJSrPlqw52PQ9laub&sz=w1600" "img/bankhall/04.jpg"
dl "${DRV}1HriidRG9lya3xNBGDu4tyqyTgnr6FH5p&sz=w1600" "img/bankhall/05.jpg"
dl "${DRV}1xkZCjZGyNEOjYjrQDHLYwcTeQBPc8v-U&sz=w1600" "img/bankhall/06.jpg"
dl "${DRV}1x89NyerWmX8FCljSZcFL-smC3xnJCN4Z&sz=w1600" "img/bankhall/07.jpg"
dl "${DRV}1je62-Xvam-o3lUQj0rKPHXMdPp_15SNR&sz=w1600" "img/bankhall/08.jpg"

echo "────────── Casa Luz (Drive — same set as the COS deck) ──────────"
dl "${DRV}1sM8-EoIaPgl4PGYzXVInzWqigv8vQslr&sz=w1600" "img/luz/01.jpg"
dl "${DRV}1Gv5RFV7ICViuqVIAjMmNZ_rvc0Ws5--X&sz=w1600" "img/luz/02.jpg"
dl "${DRV}1qtLJcFpH8rEN2ah2D6m3GNAOUeb16181&sz=w1600" "img/luz/03.jpg"
dl "${DRV}1xSzQW6DfHTX0epHkVeT52G1eF7PuwwNL&sz=w1600" "img/luz/04.jpg"
dl "${DRV}1lGBBJYbUiD7ejSGVXZ1LlbvkMW-LdfQh&sz=w1600" "img/luz/05.jpg"
dl "${DRV}1W-ToX7uu7crYajVttmULJXT0GnUsdQr8&sz=w1600" "img/luz/06.jpg"
dl "${DRV}1ImJjY2jmrI3AijiYHRbIgXLQFBlJIFok&sz=w1600" "img/luz/07.jpg"
dl "${DRV}1UQb-ORvm86RAvJ5qTO3xnqHjfZhVAnR6&sz=w1600" "img/luz/08.jpg"


echo "────────── Round 2 · Andrea Raisfeld brownstones (Drive) ──────────"
# Upper West Side Brownstone (Manhattan)
dl "${DRV}1sfY6tnDCUVP1tn8uj369W1elz7J48FSi&sz=w1600" "img/raisfeld/nyc195/01.jpg"
dl "${DRV}1BZZi3zDpIetpQnIRyj9HqPg4MB-IGRiW&sz=w1600" "img/raisfeld/nyc195/02.jpg"
dl "${DRV}1LPrxdtglKjmkM7DGu8-SdZgLJyH5dQIg&sz=w1600" "img/raisfeld/nyc195/03.jpg"
dl "${DRV}1UheHxMf8r_M_IKSBvi1rTRMTJ7aqW5yc&sz=w1600" "img/raisfeld/nyc195/04.jpg"
dl "${DRV}1VQOJYsnlVTQ55-2F1XBwVxhUr4LYG15u&sz=w1600" "img/raisfeld/nyc195/05.jpg"
dl "${DRV}1dvTFs1OrliySsvoNBUvcDIWH2LWlCBur&sz=w1600" "img/raisfeld/nyc195/06.jpg"
# West Village Brownstone (Manhattan)
dl "${DRV}1OArUUA_kT_01gbvm6NF0oO05XFY71y0Z&sz=w1600" "img/raisfeld/nyc293/01.jpg"
dl "${DRV}1SWWFQ8AKVlkH2I7Zz52hV51VMLNw3Zry&sz=w1600" "img/raisfeld/nyc293/02.jpg"
dl "${DRV}1Ooo36ykbZ2WYnoBpb-66AkGDYm8_IdC-&sz=w1600" "img/raisfeld/nyc293/03.jpg"
dl "${DRV}1ahJTjH4Bvi8e66IlCppcy9e1yE-6tMVe&sz=w1600" "img/raisfeld/nyc293/04.jpg"
dl "${DRV}1hzarmPxzYXuQopgEm1hQiGZo7DvUrSxX&sz=w1600" "img/raisfeld/nyc293/05.jpg"
dl "${DRV}1310amyRetYETdqtlEHUurtLaNqpgbhiV&sz=w1600" "img/raisfeld/nyc293/06.jpg"
dl "${DRV}1LlQz88-TZnddHssMC2HQH46W69h224_T&sz=w1600" "img/raisfeld/nyc293/07.jpg"
dl "${DRV}1VedVrd5zAGMMJtIO5hVNNC2zwmivSaVT&sz=w1600" "img/raisfeld/nyc293/08.jpg"
dl "${DRV}1jjoRnaHIuLxcbGIonu8C_cEyesq6MKAK&sz=w1600" "img/raisfeld/nyc293/09.jpg"
dl "${DRV}1O93pE6BtulocCx24wJC9rAkEDWChQl58&sz=w1600" "img/raisfeld/nyc293/10.jpg"
dl "${DRV}1WXR9t1-VFaUKNQXFfW2flKPiSKcvmboG&sz=w1600" "img/raisfeld/nyc293/11.jpg"
# Upper East Side Brownstone (Manhattan)
dl "${DRV}1iYA8iYCapSGFs2D6Ka_Qzm5Z21ZWX7gP&sz=w1600" "img/raisfeld/nyc323/01.jpg"
dl "${DRV}1ZI-BjnJSpAvs3yFcl5tYeAAu_ySIXdL1&sz=w1600" "img/raisfeld/nyc323/02.jpg"
dl "${DRV}10d5iyF0Cr67lLKa2f89CllXGXOamY4Q-&sz=w1600" "img/raisfeld/nyc323/03.jpg"
dl "${DRV}13ybWyUZq7g3oWgNn47cGZJ3bNibLJKWL&sz=w1600" "img/raisfeld/nyc323/04.jpg"
dl "${DRV}1jTNQlY_BLf7pmVHub08OkkU4YQDzMlhO&sz=w1600" "img/raisfeld/nyc323/05.jpg"
dl "${DRV}11xblTVvBYJyif54Alg9dike5BVg2u4Bx&sz=w1600" "img/raisfeld/nyc323/06.jpg"
dl "${DRV}1mhmqJn2ymxTj-8rkhaptlth3vAk-jpaw&sz=w1600" "img/raisfeld/nyc323/07.jpg"
# Manhattan Brownstone II (Manhattan)
dl "${DRV}1309hlceZANUKdBe-0B-pUEF5s_-VMHbE&sz=w1600" "img/raisfeld/nyc327/01.jpg"
dl "${DRV}1oXOj2ImxC6Uzc0rmDJuICqRkp1SE455N&sz=w1600" "img/raisfeld/nyc327/02.jpg"
dl "${DRV}1CGXgFtoOwqxTA6NROeScKslu4CVm-Vrk&sz=w1600" "img/raisfeld/nyc327/03.jpg"
dl "${DRV}1jHKysTe1GX_h8G3AtoF0ZXZanL5k6l5r&sz=w1600" "img/raisfeld/nyc327/04.jpg"
dl "${DRV}1NUmGvl7ENG6bF4q6zg0oDfklc6YpY7ya&sz=w1600" "img/raisfeld/nyc327/05.jpg"
dl "${DRV}1IdqcR_BNNkmLhJuPVR0mjLo27DAB2AmE&sz=w1600" "img/raisfeld/nyc327/06.jpg"
dl "${DRV}1Iy2keCvz9d3iPpmMAcv6RCj1enYuyF7J&sz=w1600" "img/raisfeld/nyc327/07.jpg"
dl "${DRV}1HzNbbgKtYH-INAOc6FAkkDGrXGY02lnx&sz=w1600" "img/raisfeld/nyc327/08.jpg"
dl "${DRV}1lTG5WH_TXVYe9xq1JtTscaSaPVhZFDje&sz=w1600" "img/raisfeld/nyc327/09.jpg"
# Manhattan Modern Apartment (Manhattan)
dl "${DRV}1dd4viz8jDHbvivQGPU1Zldkx6ZY05opA&sz=w1600" "img/raisfeld/nyc315/01.jpg"
dl "${DRV}1WJ6_DnHtKM_BRZZp4-VC9N9mrLaEuYsT&sz=w1600" "img/raisfeld/nyc315/02.jpg"
dl "${DRV}1u0NDaTYc481wGLRj8ihWAyzuS801W6Zr&sz=w1600" "img/raisfeld/nyc315/03.jpg"
dl "${DRV}1Kp83OHztSPtglsaeGaCpkKRbBvyN93OI&sz=w1600" "img/raisfeld/nyc315/04.jpg"
dl "${DRV}1IqYO311LK5AkP2yiF_nP8slgbwFlx2Y8&sz=w1600" "img/raisfeld/nyc315/05.jpg"
dl "${DRV}1AokJNqrB2Ifn8N4UtsgUlyWihbce10y5&sz=w1600" "img/raisfeld/nyc315/06.jpg"
dl "${DRV}1Iw5kHRnQpfuoGGkZFZzkkXMvEok23nm6&sz=w1600" "img/raisfeld/nyc315/07.jpg"
# NoMad Penthouse (Manhattan)
dl "${DRV}1JzIaGn-t5xs4EsB7I8cXvlEV-ewpr1jD&sz=w1600" "img/raisfeld/nyc322/01.jpg"
dl "${DRV}1MPAjT0gMkmGbMyZEhhMq_OBmahPA2H3p&sz=w1600" "img/raisfeld/nyc322/02.jpg"
dl "${DRV}1NT_JQALS0YByYltPWLIkKjdiWpy_XnD9&sz=w1600" "img/raisfeld/nyc322/03.jpg"
dl "${DRV}1C9Vnt-vZ46JEo-_Hv6L_oQnDeHwlD_Jv&sz=w1600" "img/raisfeld/nyc322/04.jpg"
dl "${DRV}1kV_CvBiso1e3y_ASXd_2qk7z2vYbISsV&sz=w1600" "img/raisfeld/nyc322/05.jpg"
dl "${DRV}1BwIXBJOLPiw-IL7E-7Dfbn8EcT50ejLO&sz=w1600" "img/raisfeld/nyc322/06.jpg"
dl "${DRV}1IPZG6vF3BqwwTwrQJEYbhYk9SI3RJHb4&sz=w1600" "img/raisfeld/nyc322/07.jpg"
# Brooklyn Brownstone (Brooklyn)
dl "${DRV}1feNAVsvdec4h64uXZfdrr6ahF58DblMj&sz=w1600" "img/raisfeld/bk410/01.jpg"
dl "${DRV}1ra_vekUQesET1_8S7ZCzUhkeU0FNmqvC&sz=w1600" "img/raisfeld/bk410/02.jpg"
dl "${DRV}1nlhurkf2kcMGhybJNsZWJYmEE0jIekbE&sz=w1600" "img/raisfeld/bk410/03.jpg"
dl "${DRV}1SBwNG0giIRspxMx5hyDaWUZPgxS4254l&sz=w1600" "img/raisfeld/bk410/04.jpg"
dl "${DRV}1aqiGKtb04FLQQVS6DqpDyXz1Ws--kGxR&sz=w1600" "img/raisfeld/bk410/05.jpg"
dl "${DRV}1hHdh_AV8oP57vwxcWZgAB17HEa9lWT1i&sz=w1600" "img/raisfeld/bk410/06.jpg"
dl "${DRV}1n1hNNEzPGSDceRSrr6NoR90lES262xBL&sz=w1600" "img/raisfeld/bk410/07.jpg"
dl "${DRV}1lxqGczthGvWiaeIls9DHgSmghNmt7vE1&sz=w1600" "img/raisfeld/bk410/08.jpg"
dl "${DRV}1prJIELEqIAITuqvLdz9fNXNf31937i80&sz=w1600" "img/raisfeld/bk410/09.jpg"
dl "${DRV}1XpWB1-FbVb3KMvhW5LVtsGjFNahHcEjT&sz=w1600" "img/raisfeld/bk410/10.jpg"
dl "${DRV}11VtQA4VSFiLSqf7PZOll0Q_4cYCzY47G&sz=w1600" "img/raisfeld/bk410/11.jpg"
dl "${DRV}1PZk-IPYBNw3NFvmBWjR-qkw4d8My-cYr&sz=w1600" "img/raisfeld/bk410/12.jpg"
# Brooklyn Maximalist Townhouse (Brooklyn)
dl "${DRV}1sBFgSFf8GowXy-ejIPH1qCYXDeUtBOCf&sz=w1600" "img/raisfeld/bk437/01.jpg"
dl "${DRV}1BlYi2jhxzBnL4ekCN9b2SQ0gAF6wIkiP&sz=w1600" "img/raisfeld/bk437/02.jpg"
dl "${DRV}1u0SwXyYC3s0Nmssnj_28Wl2gaylAn4tH&sz=w1600" "img/raisfeld/bk437/03.jpg"
dl "${DRV}16pVwWmHd7YZwFk-aX4XriwKUAyFv1v3M&sz=w1600" "img/raisfeld/bk437/04.jpg"
dl "${DRV}1JkrMN2tWXsnM4DMq58f-yVHYwrT_Qqdq&sz=w1600" "img/raisfeld/bk437/05.jpg"
dl "${DRV}16U4fxvLzBPgm9jFD6uclZuQ9gBEvHqU1&sz=w1600" "img/raisfeld/bk437/06.jpg"
dl "${DRV}1H0cjl9Ui0N2TpzgsIzd4ETeh15NxG-v7&sz=w1600" "img/raisfeld/bk437/07.jpg"
dl "${DRV}1P3AWLOcdBac1w3j-_b-aXnz2TrOQnhci&sz=w1600" "img/raisfeld/bk437/08.jpg"
dl "${DRV}1nBY7W-Gq656RXc4s6xo-vjQdp5BZACFv&sz=w1600" "img/raisfeld/bk437/09.jpg"
dl "${DRV}12G5oEkGvs2XbUAUYJZJjHhJp8efndEYL&sz=w1600" "img/raisfeld/bk437/10.jpg"
# Brooklyn Event / Showroom Space (Brooklyn)
dl "${DRV}1EIop3bffnQdQL7ZnVWolakE23AQlqFXj&sz=w1600" "img/raisfeld/bk166/01.jpg"
dl "${DRV}1_l2X2vHWm5tFQ3DP-l_YofCyn8G2tBUO&sz=w1600" "img/raisfeld/bk166/02.jpg"
dl "${DRV}1kjiCarNZXqLCbUa7CMd588BMM-bnFdA5&sz=w1600" "img/raisfeld/bk166/03.jpg"
dl "${DRV}15ZbjAWw8S_ogEAD1ZVQqsBHWLsiHV9rW&sz=w1600" "img/raisfeld/bk166/04.jpg"
dl "${DRV}1LjN354h_ilM5wFuZ432ghx1lB-4hO41p&sz=w1600" "img/raisfeld/bk166/05.jpg"
dl "${DRV}14dyw5FvDCk3KbRPK2ASBRjZTVOAyD7ix&sz=w1600" "img/raisfeld/bk166/06.jpg"
dl "${DRV}1quOOpOdWBMqlqCuRc-F4EfO6pIxKiQU2&sz=w1600" "img/raisfeld/bk166/07.jpg"
dl "${DRV}1pS1AQi8USXqvb5mSZ5XalK-pT9uf0Mvp&sz=w1600" "img/raisfeld/bk166/08.jpg"
dl "${DRV}1yABTqONu_m4kn77livdKcylrYQuFk9pR&sz=w1600" "img/raisfeld/bk166/09.jpg"
dl "${DRV}1SvYhwf2urAGuOzhI_vzikUZBRN2rmrC_&sz=w1600" "img/raisfeld/bk166/10.jpg"
dl "${DRV}111KQ-MqypGrCXFthbx3IgIXA9HwtJC2_&sz=w1600" "img/raisfeld/bk166/11.jpg"
dl "${DRV}1cMRrsGOBudajYaAn6b6HUpD-5nyt82lS&sz=w1600" "img/raisfeld/bk166/12.jpg"
dl "${DRV}1bnKXlPvMHwn6h_A3TeVVPM_YmFq0ZgdK&sz=w1600" "img/raisfeld/bk166/13.jpg"
dl "${DRV}125Lac243QNUZvBdtxoYHFTJTNYP0SLd6&sz=w1600" "img/raisfeld/bk166/14.jpg"


echo "────────── Casa Maxima (Tribeca · Cocoon) ──────────"
R="https://cocoonflexspaces.com/rent-casa-maxima-in-tribeca-nyc/"
dl "https://cocoonflexspaces.com/wp-content/uploads/2024/10/cocoon-casa-maxima-living-room-pink-venetian-plaster.jpg" "img/maxima/01.jpg" "$R"
dl "https://cocoonflexspaces.com/wp-content/uploads/2024/10/cocoon-casa-maxima-living-room-fireplace-grand-piano-wall-art-gold-columns.jpg" "img/maxima/02.jpg" "$R"
dl "https://cocoonflexspaces.com/wp-content/uploads/2024/10/cocoon-casa-maxima-sitting-room-large-yellow-circular-couch-large-windows.jpg" "img/maxima/03.jpg" "$R"
dl "https://cocoonflexspaces.com/wp-content/uploads/2024/10/cocoon-casa-maxima-living-room-dining-area-gold-columns.jpg" "img/maxima/04.jpg" "$R"
dl "https://cocoonflexspaces.com/wp-content/uploads/2024/10/cocoon-casa-maxima-dining-area-chandelier.jpg" "img/maxima/05.jpg" "$R"
dl "https://cocoonflexspaces.com/wp-content/uploads/2024/10/cocoon-casa-maxima-kitchen-caesar-stone-countertops.jpg" "img/maxima/06.jpg" "$R"
dl "https://cocoonflexspaces.com/wp-content/uploads/2024/10/cocoon-casa-maxima-foyer-unique-wall-art.jpg" "img/maxima/07.jpg" "$R"
dl "https://cocoonflexspaces.com/wp-content/uploads/2024/10/cocoon-casa-maxima-sitting-room-with-two-entrances.jpg" "img/maxima/08.jpg" "$R"


echo "────────── Location Department · Manhattan townhouses ──────────"
# A Chelsea townhouse (LD #2044)
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/2044-LD_001_hero.jpg" "img/ld/2044/01.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/2044-LD_026.jpg" "img/ld/2044/02.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/2044-LD_002.jpg" "img/ld/2044/03.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/2044-LD_028.jpg" "img/ld/2044/04.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/2044-LD_117.jpg" "img/ld/2044/05.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/2044-LD_077.jpg" "img/ld/2044/06.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/2044-LD_106.jpg" "img/ld/2044/07.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/2044-LD_126.jpg" "img/ld/2044/08.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/2044-LD_043.jpg" "img/ld/2044/09.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/2044-LD_111.jpg" "img/ld/2044/10.jpg"
# A Chelsea townhouse (LD #2060)
dl "https://www.locationdepartment.net/wp-content/uploads/2024/08/LD_2060_Int_19.jpg" "img/ld/2060/01.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2024/08/LD_2060_Int_40.jpg" "img/ld/2060/02.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2024/08/LD_2060_Int_14.jpg" "img/ld/2060/03.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2024/08/LD_2060_Int_36.jpg" "img/ld/2060/04.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2024/08/LD_2060_Int_42.jpg" "img/ld/2060/05.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2024/08/LD_2060_Ext_8.jpg" "img/ld/2060/06.jpg"
# A Chelsea townhouse (LD #2253)
dl "https://www.locationdepartment.net/wp-content/uploads/2023/08/2253-LD_008.jpg" "img/ld/2253/01.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2023/08/2253-LD_006.jpg" "img/ld/2253/02.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2023/08/2253-LD_017.jpg" "img/ld/2253/03.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2023/08/2253-LD_034.jpg" "img/ld/2253/04.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2023/08/2253-LD_039.jpg" "img/ld/2253/05.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2023/08/2253-LD_054.jpg" "img/ld/2253/06.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2023/08/2253-LD_086.jpg" "img/ld/2253/07.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2023/08/2253-LD_078.jpg" "img/ld/2253/08.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2023/08/2253-LD_117.jpg" "img/ld/2253/09.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2023/08/2253-LD_130.jpg" "img/ld/2253/10.jpg"
# A Chelsea townhouse (LD #2593)
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/2593/2593-LD_011__scaled_640.jpg" "img/ld/2593/01.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/2593/2593-LD_005__scaled_640.jpg" "img/ld/2593/02.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/2593/2593-LD_095.jpg" "img/ld/2593/03.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/2593/2593-LD_024__scaled_640.jpg" "img/ld/2593/04.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/2593/2593-LD_034__scaled_640.jpg" "img/ld/2593/05.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/2593/2593-LD_035__scaled_640.jpg" "img/ld/2593/06.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/2593/2593-LD_050__scaled_640.jpg" "img/ld/2593/07.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/2593/2593-LD_051__scaled_640.jpg" "img/ld/2593/08.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/2593/2593-LD_014__scaled_640.jpg" "img/ld/2593/09.jpg"
# A Chelsea townhouse (LD #3333)
dl "https://www.locationdepartment.net/wp-content/uploads/2018/10/3333-LD_029.jpg" "img/ld/3333/01.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2018/10/3333-LD_033.jpg" "img/ld/3333/02.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2018/10/3333-LD_081.jpg" "img/ld/3333/03.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2018/10/3333-LD_036.jpg" "img/ld/3333/04.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2018/10/3333-LD_014.jpg" "img/ld/3333/05.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2018/10/3333-LD_024.jpg" "img/ld/3333/06.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2018/10/3333-LD_028.jpg" "img/ld/3333/07.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2018/10/3333-LD_125.jpg" "img/ld/3333/08.jpg"
# A East Village townhouse (LD #2580)
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/2580/2580-LD_005__scaled_640.JPG" "img/ld/2580/01.jpg"
# A Greenwich Village townhouse (LD #2223)
dl "https://www.locationdepartment.net/wp-content/uploads/2023/03/LD_2223_Int_8.jpeg" "img/ld/2223/01.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2023/03/LD_2223_Int_22.jpeg" "img/ld/2223/02.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2023/03/LD_2223_Int_5.jpeg" "img/ld/2223/03.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2023/03/LD_2223_Int_26.jpeg" "img/ld/2223/04.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2023/03/LD_2223_Int_44.jpeg" "img/ld/2223/05.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2023/03/LD_2223_Int_59.jpeg" "img/ld/2223/06.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2023/03/LD_2223_Int_96.jpeg" "img/ld/2223/07.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2023/03/LD_2223_Ext_3.jpeg" "img/ld/2223/08.jpg"
# A Greenwich Village townhouse (LD #9005)
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/LD_9005_Int_5.jpeg" "img/ld/9005/01.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/LD_9005_Int_13.jpeg" "img/ld/9005/02.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/LD_9005_Int_2.jpeg" "img/ld/9005/03.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/LD_9005_Int_14.jpeg" "img/ld/9005/04.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/LD_1324_Int_25.jpeg" "img/ld/9005/05.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/ResizeofRotationofDSCF0111.JPG" "img/ld/9005/06.jpg"
# A Harlem townhouse (LD #2244)
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/2244/bb18_resize.jpg" "img/ld/2244/01.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/2244/bb19_resize.jpg" "img/ld/2244/02.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/2244/bb7_resize.jpg" "img/ld/2244/03.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/2244/bb16_resize.jpg" "img/ld/2244/04.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/2244/bb13_resize.jpg" "img/ld/2244/05.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/2244/bb3_resize.jpg" "img/ld/2244/06.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/2244/bb70_resize.jpg" "img/ld/2244/07.jpg"
# A Murray Hill townhouse (LD #2136)
dl "https://www.locationdepartment.net/wp-content/uploads/2022/04/LD_2136_Int_22.jpeg" "img/ld/2136/01.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2022/04/LD_2136_Int_13.jpeg" "img/ld/2136/02.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2022/04/LD_2136_Int_8.jpeg" "img/ld/2136/03.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2022/04/LD_2136_Int_41.jpeg" "img/ld/2136/04.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2022/04/LD_2136_Int_39.jpeg" "img/ld/2136/05.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2022/04/LD_2136_S_14.jpeg" "img/ld/2136/06.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2022/04/LD_2136_Int_20.jpeg" "img/ld/2136/07.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2022/04/LD_2136_Int_28.jpeg" "img/ld/2136/08.jpg"
# A Upper East Side townhouse (LD #2490)
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/2490/2490-LD_001_hero__scaled_640.jpg" "img/ld/2490/01.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/2490/2490-LD_002__scaled_640.jpg" "img/ld/2490/02.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/2490/2490-LD_014__scaled_640.jpg" "img/ld/2490/03.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/2490/2490-LD_026__scaled_640.jpg" "img/ld/2490/04.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/2490/2490-LD_034__scaled_640.jpg" "img/ld/2490/05.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/2490/2490-LD_036__scaled_640.jpg" "img/ld/2490/06.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/2490/2490-LD_039.jpg" "img/ld/2490/07.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/2490/2490-LD_103__scaled_640.jpg" "img/ld/2490/08.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/2490/2490-LD_102__scaled_640.jpg" "img/ld/2490/09.jpg"
# A Upper West Side townhouse (LD #2132)
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/LD_2132_005.jpg" "img/ld/2132/01.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/LD_2132_018.jpg" "img/ld/2132/02.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/LD_2132_039.jpg" "img/ld/2132/03.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/LD_2132_051.jpg" "img/ld/2132/04.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/LD_2132_046.jpg" "img/ld/2132/05.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/LD_2132_056_hero.jpg" "img/ld/2132/06.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/LD_2132_065.jpg" "img/ld/2132/07.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/LD_2132_076.jpg" "img/ld/2132/08.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/LD_2132_074.jpg" "img/ld/2132/09.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/LD_2132_087.jpg" "img/ld/2132/10.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/2132/DSC_7318_resize.JPG" "img/ld/2132/11.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/2132/DSC_7367_resize.JPG" "img/ld/2132/12.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/2132/DSC_7430_resize.JPG" "img/ld/2132/13.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/2132/DSC_7187_resize.JPG" "img/ld/2132/14.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/2132/DSC_7285_resize.JPG" "img/ld/2132/15.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2017/07/2132/DSC_7343_resize.JPG" "img/ld/2132/16.jpg"
# A Upper West Side townhouse (LD #2267)
dl "https://www.locationdepartment.net/wp-content/uploads/2024/01/LD_2267_2FL_1.jpg" "img/ld/2267/01.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2024/01/LD_2267_2FL_27.jpg" "img/ld/2267/02.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2024/01/LD_2267_2FL_18.jpg" "img/ld/2267/03.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2024/01/LD_2267_2FL_20.jpg" "img/ld/2267/04.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2024/01/LD_2267_3FL_6.jpg" "img/ld/2267/05.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2024/01/LD_2267_3FL_1.jpg" "img/ld/2267/06.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2024/01/LD_2267_1FL_8.jpg" "img/ld/2267/07.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2024/01/LD_2267_Ext_3.jpeg" "img/ld/2267/08.jpg"
dl "https://www.locationdepartment.net/wp-content/uploads/2024/01/LD_2267_Ext_4.jpeg" "img/ld/2267/09.jpg"


echo "────────── Casa Victoria (Chelsea · Cocoon) ──────────"
R="https://cocoonflexspaces.com/casa-victoria/"
dl "https://cocoonflexspaces.com/wp-content/uploads/2024/10/cocoon-casa-victoria-main-living-room-side.jpg" "img/victoria/01.jpg" "$R"
dl "https://cocoonflexspaces.com/wp-content/uploads/2024/10/cocoon-casa-victoria-lounge-room.jpg" "img/victoria/02.jpg" "$R"
dl "https://cocoonflexspaces.com/wp-content/uploads/2024/10/cocoon-casa-victoria-living-room-dining.jpg" "img/victoria/03.jpg" "$R"
dl "https://cocoonflexspaces.com/wp-content/uploads/2024/10/cocoon-casa-victoria-kitchen-area-side-view.jpg" "img/victoria/04.jpg" "$R"
dl "https://cocoonflexspaces.com/wp-content/uploads/2024/10/cocoon-casa-victoria-reading-room-detail.jpg" "img/victoria/05.jpg" "$R"
dl "https://cocoonflexspaces.com/wp-content/uploads/2024/10/cocoon-casa-victoria-library-corridor-bookshelves-vertical.jpg" "img/victoria/06.jpg" "$R"
dl "https://cocoonflexspaces.com/wp-content/uploads/2024/10/cocoon-casa-victoria-living-tv-room.jpg" "img/victoria/07.jpg" "$R"
dl "https://cocoonflexspaces.com/wp-content/uploads/2024/10/cocoon-casa-victoria-living-room-art-detail.jpg" "img/victoria/08.jpg" "$R"

echo ""
echo "────────── Resizing to ≤1600px ──────────"
if command -v magick >/dev/null 2>&1 || command -v convert >/dev/null 2>&1; then
  CMD="magick"; command -v $CMD >/dev/null 2>&1 || CMD="convert"
  for f in img/joy/*.jpg img/elliot/*.jpg img/brutal/*.jpg img/halloway/*.jpg img/skylight/*.jpg img/fountain/*.jpg img/lazarus/*.jpg img/stagehouse/*.jpg img/tower/*.jpg img/skyline/*.jpg img/bankhall/*.jpg img/luz/*.jpg img/raisfeld/*/*.jpg img/maxima/*.jpg img/victoria/*.jpg img/ld/*/*.jpg; do
    [ -f "$f" ] || continue
    $CMD "$f" -resize "1600x1600>" -strip -quality 84 "$f.tmp" && mv "$f.tmp" "$f"
  done
  echo "  ✓ resized"
else
  echo "  (ImageMagick not installed — skipping resize. 'brew install imagemagick' if wanted.)"
fi

echo ""
echo "────────── Rewriting index.html to local paths ──────────"
[ -f index.html.bak ] || cp index.html index.html.bak
python3 - "$MANIFEST" <<'PYEOF'
import sys
pairs = []
with open(sys.argv[1]) as f:
    for line in f:
        if '\t' in line:
            url, local = line.rstrip('\n').split('\t')
            pairs.append((url, local))
src = open('index.html').read()
count = 0
for url, local in pairs:
    if url in src:
        src = src.replace(f'src="{url}"', f'src="{local}"')
        count += 1
open('index.html', 'w').write(src)
print(f"  ✓ rewrote {count} image references to local paths")
remaining = src.count('src="https://')
print(f"  {'⚠' if remaining else '✓'} {remaining} remote image references remain" + (" — see FAILED lines above, fix and re-run" if remaining else ""))
PYEOF

echo ""
echo "  ✓ Done. Open index.html to preview."
