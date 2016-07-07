
{split, take, join, lists-to-obj, sum} = require 'prelude-ls'
{sleep} = require "aea"

random = require \randomstring

Ractive.components['interactive-table'] = Ractive.extend do
    oninit: ->
        if (@get \id) is \will-be-random
            # then make it random
            @set \id random.generate 7
            #console.log "Table id is automatically generated: ", @get \id
        col-list = @get \cols |> split ','
        @set \columnList, col-list
        self = @
        #console.log "table content", @get \content

        @on do
            activated: (...args) ->
                index = (args.0.keypath |> split '.').1 |> parse-int
                console.log "activated!!!", args, index
                curr-index = @get \clickedIndex
                if index is curr-index
                    console.log "Give tooltip!"
                    @fire \showModal
                @set \clickedIndex, index

            close-modal: ->
                self = @
                $ "\##{@get 'id'}-modal" .modal \hide
                <- sleep 300ms
                self.fire \giveTooltip


            give-tooltip: ->
                self = @
                i = 0
                <- :lo(op) ->
                    <- sleep 150ms
                    self.set \editTooltip, on
                    <- sleep 150ms
                    self.set \editTooltip, off
                    if ++i is 2
                        return op!
                    lo(op)


            save-and-exit: ->
                index = @get \clickedIndex
                console.log "clicked to save and hide", index
                line = (@get \tabledata)[index]
                #console.log "line is: ", line
                @get \db .put line, (err, res) ->
                    if err
                        console.log "ERR: Table:", err
                    else
                        console.log "INFO: Table: ", res
                @set \clickedIndex, null
                @set \editable, no

            toggle-editing: ->
                editable = @get \editable
                @set \editable, not editable

            revert: ->
                alert "Changes Reverted!"

            show-modal: ->
                id = @get \id
                console.log "My id: ", id
                $ "\##{id}-modal" .modal \show

    template: '#interactive-table'
    data:
        id: \will-be-random
        db: null
        tabledata: null
        editable: false
        clicked-index: null
        cols: null
        column-list: null
        editTooltip: no
        is-editing-line: (index) ->
            editable = @get \editable
            clicked-index = @get \clickedIndex
            editable and (index is clicked-index)
