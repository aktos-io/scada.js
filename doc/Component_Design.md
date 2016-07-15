## Component design

1. Use `Ractive.components['your-component-name'] = Ractive.extend ...`

    Reason:
        Otherwise, component users must define your component in their
        ractive instance as `{... components: {'your-component': ...}}` which
        will lead verbose, unnecessarily complex and possibly inconsistent code.  

2. Use `isolated: yes` in components.

## Testing

If not matches with **MOST IMPORTANT**: Your component is alpha, not ready to go.
If not matches with **IMPORTANT**: Your component is beta, ready to go with parallel development effort
If not matches with **MEDIUM**: Your component is ready to go, but buggy.
If not matches with **LOW**: Your component is ready to go, another developer might finalize it.

If matches all: Congratulations! Your component is rock solid!

1. **MOST IMPORTANT** Use your component in `../pages/showcase.jade`
2. **IMPORTANT** Place a simple ractive variable by your component,
    SEE THAT: we can observe variables.

3. **IMPORTANT** Place 2 untied instances of your component.

   SEE THAT:
       Your component does not interfere with new instances.

   TIP:
       1. Does your component uses any elements which have static `id` field? BUG!

4. **MOST IMPORTANT** Place one or more of:
    * a pair of tied instances
    * `<input .../>` field
    * streaming live feed

    that will change component's variable.

   SEE THAT:
        Component properly updates itself whenever main Ractive instance's variable is changed.

5. **IMPORTANT** Place a checkbox that will toggle an `{{#if}} <my-component /> {{/if}}` block.

   SEE THAT:
        Your component appears and disappears correctly.

   TIP:
        Check that `oninit()` and `onrender()` functions work correctly in your
        component

6. **MEDIUM** Test your code in mobile.  

    SEE THAT:
        Your component is usable in mobile device.

7. **MEDIUM** Set width and height to different sizes

    SEE THAT:
        Your component resizes correctly.

8. **LOW** Your component must match with theme colors

    SEE THAT:
        It looks good.

    TIP:
        Ask a friend.

## Example component

Look at the [example-component](./example-component) is used in [showcase](../pages/showcase.jade).
