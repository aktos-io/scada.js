# Router

Add the `router` component in your webapp:

        router(
                offset="50"  # <- Offset for top menu (in "px") (Optional)
               )

# Anchors

Creating anchor:

        anchor my-anchor

There are 4 types of anchors:

1. Scroll in current page:

        a(href="#my-anchor") Scroll to my-anchor

2. Switch page:

        a(href="#/other-page") Go to the "other-page"

        a(newtab href="#/other-page") Go to the "other-page" in new tab

        a(href="#/other-page#some-anchor") Go to the "other-page" and scroll to "some-anchor"

3. Open an external link:

        a(href="http://example.com") Go to example.com (in new tab, by default)

        a(curr-window href="http://example.com") Go to example.com (in current window)
        
4. Download a static file:

        a.icon(download href="sgw-example.json" tooltip="Download the example project")
            icon.download.pink

# Navigating Programmatically

`window.location.hash` is listened by the `router` component. 

If the hash is set by any method, `router` will handle the navigation. 