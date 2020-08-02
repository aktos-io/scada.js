## Component Design Guide

1. Register components per Ractive instance:

       Ractive.components['your-component-name'] = Ractive.extend {...}

2. Use `isolated: yes` in components if there is no obvious reason.


3. Components MUST NOT modify their input data if there is no obvious reason to do so.

   > Eg: A `log` input is a read-write input, so a component may show log content and append a new event. That's normal. On the other hand, a `dropdown` data is considered read-only, so the component should not change the data, instead, it has to set another variable (attribute) for the selection. Modifying the input data with any kind of temporary data is **strictly disallowed**.


## Test Your Components

* If not matches with **MOST IMPORTANT**: Your component is alpha, not ready to go.
* If not matches with **IMPORTANT**: Your component is beta, ready to go with parallel development effort
* If not matches with **MEDIUM**: Your component is ready to go, but buggy.
* If not matches with **LOW**: Your component is ready to go, another developer might finalize it.
* If matches all: Congratulations! Your component is rock solid!

| #  | Importance     | Task                                                                                                                                                                               | See                                                                                                                                               | Tip                                                                                                                            |
|----|----------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------|
| 1  | MOST IMPORTANT | Implement example usage of your component in `showcase/your-component.pug` as in the case of [example-component](https://github.com/aktos-io/scadajs-template/tree/master/webapps/showcase/example/index.pug)             |                                                                                                                                                   |                                                                                                                                |
| 2  | IMPORTANT      | Place a simple ractive variable by your component                                                                                                                                  | we can observe variables.                                                                                                                         |                                                                                                                                |
| 3  | IMPORTANT      | Place 2 unbound instances of your component.                                                                                                                                       | Your component does not interfere with new instances.                                                                                             | Does your component use any elements which has static `id` field?                                                              |
| 4  | MOST IMPORTANT | Place one or more of:  <ul> <li> a pair of bound instances </li> <li> `input` field </li>  <li> streaming live feed (via functions)  </li> that will change component's variable.  | Component properly updates itself whenever main Ractive instance's variable is changed.                                                           | Does your component use `observe`? Does your component implements an `.on \change` (or similar) event if it uses jQuery in it? |
| 5  | IMPORTANT      | Place a checkbox that will toggle an `{{#if}} ... {{/if}}` block.                                                                                                                  | Your component appears and disappears correctly on render and re-render.                                                                          | Check that `oninit()` and `onrender()` functions work correctly in your,component                                              |
| 6  | MEDIUM         | Test your code in mobile.                                                                                                                                                          | Your component is usable in mobile device.                                                                                                        |                                                                                                                                |
| 7  | MEDIUM         | Set width and height to different sizes                                                                                                                                            | Your component resizes correctly.                                                                                                                 |                                                                                                                                |
| 8  | LOW            | Your component must match with theme colors                                                                                                                                        | It looks good.                                                                                                                                    | Ask a friend.                                                                                                                  |
| 9  | IMPORTANT      | Add a quick checklist to `your-component.pug` to show that which tests has been performed and which tests your component passes. |                                                                                                                                                   |                                                                                                                                |
| 10 | MOST IMPORTANT | Is your component a container component (like the `page` component)? If yes, it SHOULD NOT be defined with `isolated: yes` parameter and should `{{yield}}` or `{{yield right}}` in order to place content(s) in component, not partials (`{{>content}}` or `{{>right}}`.       | Create a button in your container component, define an event handler in your main ractive instance, see you can fire that event on button click.  |                                                                                                                                |

Example checklist for `your-component.pug`:

```
//-
    Match with Design Guide status:

        [x] 1. Example implementation
        [x] 2. Simple variable
        [x] 3. Unbound instances
        [x] 4. Bound instances and/or live feed
        [x] 5. {{#if }} ... {{/if}} block
        [ ] 6. Test on mobile
        [ ] 7. Change sizes
        [x] 8. Match theme
        [x] 9. This checklist
```    
## Example component

Look at the [example-component](https://github.com/aktos-io/scadajs-template/tree/master/webapps/showcase/example) is used in [showcase](https://github.com/aktos-io/scadajs-template/tree/master/webapps/showcase).
