$.fn.select2.defaults.set("theme", "bootstrap")

$(document).ready ->
#  $("#country-select").append($("<option/>"))
#                        .attr("value", "Germany")
#                        .text("Germany")
  $("#country-select").select2
    placeholder: "Country"
    ajax:
      url: "http://localhost:3000/jurisdiction.json?view=select2",
      dataType: "json"

  $("body").on "select2:select", "#country-select", ->
    updateFactoryList()

  $("body").on "change", "#keyword-input", ->
    updateFactoryList()

  $("body").on 'shown.bs.collapse', ".collapse", ->
    $(this).text("hello")


updateFactoryList = ->
  keyword = $("#keyword-input").val()
  selected = $("#country-select").select2("data")
  if (selected.length > 0)
    country_code = selected[0].id
  console.log(country_code)
  console.log(keyword)
  url = "http://wikirate.org/company.json?view=search_factories&keyword=#{keyword}&country_code=#{country_code}"
  $.ajax(url: url, dataType: "json").done((data) ->
    data.each (factory) ->
      card = $(".card.template").clone())



