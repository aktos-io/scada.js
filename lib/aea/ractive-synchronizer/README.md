# Usage:

1. Create a synchronizer proxy

```ls
Ractive.partials["ace-editor"] = getSynchronizer RACTIVE_PREPARSE('loading.pug')
```

2. Rename actual component

```ls
Ractive.components["ace-editorASYNC"] = Ractive.extend ...
```

3. Remove `ASYNC` component from `app` bundle, load it later.

4. Send a signal to the synchronizer when component is ready:

```ls
@set '@shared.deps', {_all: true}, {+deep}
```


(see [Ractive Synchronizer](https://github.com/ceremcem/ractive-synchronizer))
