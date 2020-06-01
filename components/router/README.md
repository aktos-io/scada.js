# Router

Add the `router` component in your webapp:

        router(
                offset="50"  # <- Offset for top menu (in "px") (Optional)
               )

# Anchors

There are 4 types of anchors:

1. Scroll to an anchor in current page:

        a(href="#my-anchor") Scroll to my-anchor

2. Switch page in current webapp:

        a(href="#/other-page") Go to the "other-page"

        a(newtab href="#/other-page") Go to the "other-page" in new tab

        a(href="#/other-page#some-anchor") Go to the "other-page" and scroll to "some-anchor"

3. Open an external link:

        a(href="http://example.com") Go to example.com (in new tab, by default)

        a(href="http://example.com" curr-window) Go to example.com (in current window)
        
4. Download an asset:

        a.icon(href="sgw-example.json" download tooltip="Download the example project")
            icon.download.pink

# Creating in-app anchor target

1. Use `anchor` component to create in-app anchor target:

        anchor my-anchor

2. Then create link to scroll to the anchor:

        a(href="#my-anchor") Scroll to my-anchor
