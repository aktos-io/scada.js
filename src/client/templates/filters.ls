export pug-filters =
    # use "my-own-filter" in the pug page as follows:
    #
    #     :my-own-filter(addStart addEnd) Hello
    #
    # which will print the following output:
    #
    #     Start: Hello. The end.
    #
    'my-own-filter': (text, options) ->
        text = "Start: #{text}" if options.addStart
        text = "#{text}. The end." if options.addEnd
        text
