#!/usr/bin/env bash
set -e

# This bash script is for assisting in managing my credit freezes.
# It'll essentially attempt to open the three credit companies
# freeze sites through the primary browser.

open https://www.equifax.com/personal/credit-report-services/
open https://www.experian.com/freeze/center.html
open https://www.transunion.com/credit-freeze
