component-name = "coll-panel"
Ractive.components[component-name] = Ractive.extend do
    template: "\##{component-name}"
    isolated: yes
    onrender: ->
        __ = @
        /*
        script(type="text/javascript").
            jQuery(function ($) {
                $('.panel-heading span.clickable').on("click", function (e) {
                    if ($(this).hasClass('panel-collapsed')) {
                        // expand the panel
                        $(this).parents('.panel').find('.panel-body').slideDown();
                        $(this).removeClass('panel-collapsed');
                        $(this).find('i').removeClass('glyphicon-chevron-down').addClass('glyphicon-chevron-up');
                    }
                    else {
                        // collapse the panel
                        $(this).parents('.panel').find('.panel-body').slideUp();
                        $(this).addClass('panel-collapsed');
                        $(this).find('i').removeClass('glyphicon-chevron-up').addClass('glyphicon-chevron-down');
                    }
                });
            });
            */

        expand-button = $ @find \span.clickable
        panel-body = $ @find \.panel.panel-body
        #icon = $

        expand-button.on \click, (e) ->
            if __.get \collapsed
                # expand the panel
                __.set \collapsed, no
            else
                # collapse the panel
                __.set \collapsed, yes

    data: ->
        collapsed: yes
        type: \default
