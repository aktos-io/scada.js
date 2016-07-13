## Testing

1. Use your component in `../pages/showcase.jade`
2. Place a simple ractive variable by your component, like so:

        my-component(data="{{ x }}")
        p {{ x }}

   Reason:
       Show how your component interacts with `new Ractive()` instance.

3. Place 2 instances of your component.

   Reason:
       Prove that your component does not interfere with new instances.

   Debug:
       1. Does your component uses any elements which have static `id` field? BUG!

4. Place a checkbox that will toggle an `{{#if}} <my-component /> {{/if}}` block.

       input(type="checkbox" checked="{{ toggleMyComponent }}")
       +if('toggleMyComponent')
           my-component


    Reason:
        Prove that `oninit()` and `onrender()` functions work correctly in your
        component

5. Set width and height to different sizes to prove that your component
   does not include bad css code inside.

6. Feed a live data to your component to prove that your component can handle
   live feeds.

7. Test your code in mobile.  
