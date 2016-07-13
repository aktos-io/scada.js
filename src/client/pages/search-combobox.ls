require! {
    'prelude-ls': {
        group-by
    }
}
require! components
Ractive.DEBUG = /unminified/.test -> /*unminified*/

product-data =
    * name: "domates"
      supplier: "A_202"
      price: 25
      date: 12
      id: 47
    * name: "domates"
      supplier: "A_202"
      price: 23
      date: 17
      id: 47
    * name: "domates"
      supplier: "A_202"
      price: 24
      date: 11
      id: 47
    * name: "domates"
      supplier: "A_101"
      price: 22
      date: 45
      id: 47      
    * name: "patates"
      supplier: "A_101"
      price: 10
      date: 15
      id: 12
    * name: "patates"
      supplier: "A_101"
      price: 14
      date: 18
      id: 12
    * name: "patates"
      supplier: "A_101"
      price: 12
      date: 26
      id: 12
    * name: "patates"
      supplier: "A_202"
      price: 10
      date: 15  
      id: 12

convert-product-to-select-list= (product-data)->
    a = group-by (.name), product-data
    a = [{name: key, id:a[key]0.id} for key of a]
    console.log "group-by data: ",a
    a
    

ractive = new Ractive do
    el: '#main-output'
    template: '#main-template'
    data:
        x: 5
        product-list:  convert-product-to-select-list(product-data)