require! components

simulate-data = ->
    reasons =
        "Son kullanma tarihi geçmiş"
        "Müşteri İade"
        "Hatalı Sipariş"
        "Hayat zor"

    random = -> parse-int (Math.random! * 100)
    x = [{name: .., amount: random!} for reasons]
    x = [random! for reasons]


ractive=new Ractive do
    el: '#main-output'
    template: '#main-template'
    data:
        simulate-data: simulate-data
