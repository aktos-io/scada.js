# Initializing Router

Add `router` component in your webapp:

        router

### Attributes

`offset="50"`: Offset for top menu (in pixels) (if exists)

# Anchors

There are 3 types of anchors:

1. Scroll to an anchor in current page:

        a(href="#my-anchor") Scroll to my-anchor

2. Switch page in current webapp:

        a(href="#/other-page") Go to the "other-page"

        a(newtab href="#/other-page") Go to the "other-page" in new tab

        a(href="#/other-page#some-anchor") Go to the "other-page" and scroll to "some-anchor"

3. Open external link:

        a(href="http://example.com") Go to example.com (in new tab, by default)

        a(href="http://example.com" curr-window) Go to example.com (in current window)

# Creating in-app anchor target

1. Use `anchor` component to create in-app anchor target:

        anchor my-anchor

2. Then create link to scroll to the anchor:

        a(href="#my-anchor") Scroll to my-anchor
