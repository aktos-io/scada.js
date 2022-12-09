# Setup 

1. Download your font file (eg. "7segment.ttf" from https://torinak.com/font/7-segment)

2. Upload the font file to your website: 

    1. Create a folder named `assets`.
    2. Move your font file into the `assets` folder. 
       Contents of this folder will directly be copied to the root of your build dir.

3. Create a `.css` file that declares the font: 

    ```css
    @font-face {
        font-family: "7Segment";
        src: url("/7segment.ttf");
    }

    .seven-segment {
        font-family: "7Segment";
        letter-spacing: 2px;
    }
    ```

# Use the font in your HTML

```pug
.ui.tag.black.big.label 
    span.seven-segment(style="color: red") {{read}}
```