$.fn.select2.defaults.set "theme", "bootstrap"

# API_HOST = "https://wikirate.org"
# wikirateApiAuth = null

LINK_TARGET_HOST = "https://wikirate.org"
COUNTRY_OPTIONS_URL = "/data/wikirate_countries.json"

# EMPTY_RESULT = "<div class='alert alert-info'>no result</div>"

METRICS = {
  supplierOf: 2929015,
  suppliedBy: 2929009,
  country: 6126450
}

API_HOST = "https://wikirate.org"
# wikirateApiAuth = "wikirate:wikirat"

if wikirateApiAuth
  $.ajaxSetup
    beforeSend: (xhr) ->
      xhr.setRequestHeader "Authorization", "Basic " + btoa(wikirateApiAuth)


$(document).ready ->
  loadCountrySearch()

  # both name and country boxes have _factory-search class
  $("body").on "change", "._factory-search", ->
    updateFactoryList()

  $("body").on 'shown.bs.collapse', ".collapse", ->
    updateSuppliedCompaniesTable($(this))

  params = new URLSearchParams(window.location.search)

  unless params.get('embed-info') == "show"
    $("._embed-info").hide()

  if params.has('background')
    $('body').css("background", params.get("background"))

loadCountrySearch = () ->
  $.ajax(url: COUNTRY_OPTIONS_URL, dataType: "json").done (data) ->
    $("#country-select").select2(
      placeholder: "Country"
      allowClear: true
      data: countrySearchOptions(data)
    ).val(null).trigger('change')

countrySearchOptions = (data) ->
  opts = []
  $.each data, (_i, hash) ->
    opts.push { id: hash.name, text: hash.name, upper: hash.name.toUpperCase() }

  opts.sort (a, b) ->
    if a.upper > b.upper
      1
    else
      -1

updateFactoryList = ->
  keyword = $("#keyword-input").val()
  country = $("#country-select").val()
  accordion = $("#search-result-accordion")
  accordion.empty()
  if keyword || country
    addLoader()
    updateFactoryListAjax(keyword, country, accordion)


factoriesFoundText = (count) ->
  length = count
  length += "+" if count == 1000
  noun = "factor#{if count == 1 then 'y' else 'ies'}"
  "(Found #{length} #{noun})"

updateFactoryListAjax = (keyword, country, accordion) ->
  $.ajax(url: factorySearchURL(keyword, country), dataType: "json").done (data) ->
    $("._result-header").text(factoriesFoundText(data.length))
    if data.length == 0
# $accordion.append(EMPTY_RESULT)
    else
      for factory in data
        addFactoryCard factory, accordion

updateSuppliedCompaniesTable = ($collapse) ->
  suppliedUrl = suppliedCompaniesSearchURL $collapse.data("cardId")
  loadOnlyOnce $collapse, ($collapse) ->
    $.ajax(url: suppliedUrl, dataType: "json").done (data) ->
      buildBrandTable $collapse.find("tbody"), data

buildBrandTable = (tbody, data) ->
  tbody.find("tr.loading").remove()
  companies = {}
  $.each data.items, (_i, rel_ans) ->
    co = rel_ans.subject_company
    companies[co] ||= { id: rel_ans.subject_company_id, years: []}
    companies[co]["years"].push rel_ans.year
  $.each companies, (company, hash) ->
    addRow tbody, company, hash.years.sort(), hash.id

loadOnlyOnce = ($target, load) ->
  return if $target.hasClass("_loaded")
  $target.addClass("_loaded")
  load($target)

apiUrl = (path, query) ->
  "#{API_HOST}/#{path}.json?" + $.param(query)

factorySearchURL = (keyword, country) ->
  apiUrl "Answer/company_list", sort: "company_name", filter:
    company_name: keyword
    value: country
    metric_id: METRICS.country
    relationship:
      metric_id: METRICS.supplierOf

suppliedCompaniesSearchURL = (supplierId) ->
  apiUrl "~#{METRICS.supplierOf}+Relationship_Answer", filter:
    company_id: supplierId

addFactoryCard = (factory, $accordion) ->
  $card = $(".card.template._factory-item").clone()
  collapse_class = "id-#{factory.id}"
  $card.removeClass("template")
       .find("a.card-header")
       .text(factory.name)
       .attr("href", "div#search-result-accordion .#{collapse_class}")
       .attr("aria-controls", "search-result-accordion .#{collapse_class}")
  $card.find(".collapse").data("cardId", factory.id).addClass(collapse_class)
  $accordion.append($card)

addRow = (tbody, company, years, companyId) ->
  tbody.append $("<tr><td>#{companyLink(company, companyId)}</td><td>#{years.join(", ")}</td></tr>")

companyLink = (name, id) ->
  "<a class='text-light' href=\"#{LINK_TARGET_HOST}/~#{id}\">#{name}</a>"

addLoader = (xhr) ->
  $("._result-header").html("<span class='loading'></span>")
