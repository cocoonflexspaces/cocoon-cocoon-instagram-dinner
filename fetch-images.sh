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

mkdir -p img/joy img/elliot img/brutal img/halloway img/skylight img/fountain img/lazarus img/stagehouse img/tower img/skyline img/skyline-pool img/bankhall img/luz

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

echo ""
echo "────────── Resizing to ≤1600px ──────────"
if command -v magick >/dev/null 2>&1 || command -v convert >/dev/null 2>&1; then
  CMD="magick"; command -v $CMD >/dev/null 2>&1 || CMD="convert"
  for f in img/joy/*.jpg img/elliot/*.jpg img/brutal/*.jpg img/halloway/*.jpg img/skylight/*.jpg img/fountain/*.jpg img/lazarus/*.jpg img/stagehouse/*.jpg img/tower/*.jpg img/skyline/*.jpg; do
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
