$.fn.select2.defaults.set("theme", "bootstrap")

HOST = "http://staging.wikirate.org"
# HOST = "http://localhost:3000"
METRIC_URL = "#{HOST}/Clean_Clothes_Campaign+Supplier_of"

EMPTY_RESULT = "<div class='alert alert-info'>no result</div>"

$(document).ready ->
  $("#country-select").select2
    placeholder: "Country"
    allowClear: true
    ajax:
      url: "#{HOST}/jurisdiction.json?view=select2",
      dataType: "json"

  $("body").on "select2:select", "#country-select", ->
    updateFactoryList()

  $("body").on "change", "#keyword-input", ->
    updateFactoryList()

  $("body").on 'shown.bs.collapse', ".collapse", ->
    updateSuppliedCompaniesTable($(this))

updateSuppliedCompaniesTable = ($collapse) ->
  return unless $collapse.hasClass("not-loaded")
  $collapse.removeClass("not-loaded")
  company_url_key = $collapse.data("company-url-key")
  url = "#{METRIC_URL}+#{company_url_key}.json?view=related_companies_with_year"
  $.ajax(url: url, dataType: "json").done((data) ->
    tbody = $collapse.find("tbody")
    tbody.find("tr.loading").remove()
    for company, year of data
      row = $("<tr><td>#{company}</td><td>#{year.join(", ")}</td></tr>")
      tbody.append row
  )

updateFactoryList = ->
  $.ajax(url: searchFactoriesURL(), dataType: "json").done((data) ->
    $(".result-header").text("Found #{data.length} factor#{if data.length == 1 then "y" else "ies"}")
    $accordion = $("#search-result-accordion")
    $accordion.empty()
    if data.length == 0
      # $accordion.append(EMPTY_RESULT)
    else
      for factory in data
        addFactoryCard(factory, $accordion)
  )

searchFactoriesURL = ->
  keyword = $("#keyword-input").val()
  selected = $("#country-select").select2("data")
  if (selected.length > 0)
    country_code = selected[0].id
  "#{HOST}/company.json?view=search_factories&keyword=#{keyword}&country_code=#{country_code}"

addFactoryCard = (factory, $accordion) ->
  $card = $(".card.template").clone()
  collapse_class = "id-#{factory.id}"
  $card.removeClass("template")
       .find("h5 > a").text(factory.name)
                      .attr("href", "div#search-result-accordion .#{collapse_class}")
                      .attr("aria-controls", "search-result-accordion .#{collapse_class}")
  $card.find(".collapse").attr("data-company-url-key", factory.url_key)
                         .addClass(collapse_class)
  $accordion.append($card)
