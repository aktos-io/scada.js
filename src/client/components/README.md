## Component design

1. Use `Ractive.components['your-component-name'] = Ractive.extend ...`

    Reason:
        Otherwise, component users must define your component in their
        ractive instance as `{... components: {'your-component': ...}}` which
        will lead verbose, unnecessarily complex and possibly inconsistent code.  

2. Use `isolated: yes` in components.

## Testing

1. Use your component in `../pages/showcase.jade`
2. Place a simple ractive variable by your component so we can observe variables.
3. Place 2 instances of your component.

   Reason:
       Prove that your component does not interfere with new instances.

   Debug:
       1. Does your component uses any elements which have static `id` field? BUG!

4. Place a checkbox that will toggle an `{{#if}} <my-component /> {{/if}}` block.

   Reason:
        Prove that `oninit()` and `onrender()` functions work correctly in your
        component

5. Set width and height to different sizes to prove that your component
   does not include bad css code inside.

6. Feed a live data to your component to prove that your component can handle
   live feeds.

7. Test your code in mobile.  

## Example component

Look at the [example-component](./example-component) is used in [showcase](../pages/showcase.jade).
