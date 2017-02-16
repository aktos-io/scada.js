# Contributing

1. Find a bug, describe it (to yourself)
2. Reproduce it in `example/showcase`, create a PR. 
3. File the issue 
4. Fix the issue 
5. Open a PR. 

# Creating Pull Requests 

1. Make your fork even with upstream. 
2. Decide a feature, create your branch. 
3. When finished, merge with upstream
4. Test your current code. 
5. If everything is OK, create your PR. 
6. **If** your next feature does not depend your previous PR, switch to master branch. 
7. **If** your next feature **does** depend your previous PR, stay where you are 
8. Create a new branch, continue development. 
9. If any changes is required, switch to appropriate branch, apply your changes, go to step 3. 

# Design Principles of Components 

1. Components MUST NOT modify their input data if there is no obvious reason to do so. 

   > Eg: A `log` input is a read-write input, so a component may show log content and append a new event. That's normal. On the other hand, a `dropdown` data is considered read-only, so the component should not change the data, instead, it has to set another variable (attribute) for the selection. Modifying the input data with any kind of temporary data is strictly disallowed. 
