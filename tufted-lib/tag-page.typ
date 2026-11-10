#import sys.inputs.at("tag-template") as index
#import "tags.typ": tag-catalogue, tag-groups, tag-page

#let scope = sys.inputs.at("tag-scope")
#let lang = sys.inputs.at("tag-lang", default: "zh")
#let group = tag-groups(tag-catalogue(), scope).find(group => group.id == sys.inputs.at("active-tag"))
#show: index.template.with(
  title: group.name,
  description: "",
  date: none,
  extra-info: none,
  tags: (),
  tag-index: scope,
  lang: lang,
)
#tag-page(group, sys.inputs.at("tag-index-url"), lang: lang)
