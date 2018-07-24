# Description

This HOWTO explains how to convert sync components into async components in Ractive.

# Steps

### 1. Write a simple sync component

Write a simple component:

```js
Ractive.components.foo = Ractive.extend({
  template: `<button on-click="bar" class="red {{class}}">{{yield}}</button>`
});
```

...and use it anywhere in your application ([Playground](https://ractive.js.org/playground/?env=docs#N4IgFiBcoE5SBTAJgcwSAvgGhAZ3gEoCGAxgC4CWAbggHQkD2AtgA4MB2C7ZutAZgwYACALxDi5anQQAPMlyQAKYAB12KsvNYAbIvMhCABmo0aAPACMArpo5COAWhLaKJANYiVIC0RhehzkS4uJ4gMMhCwMCBwRgYXgB8UQCeFAjaSHFmAPTWtuwJJmTG7BgAlADcJuycAO7ipJQ0ykXpBgDkFgxIye1YRVosuvpGRWZW2oXqZBpRAMQIpGBCAIIwMETJigDMZXFFpmRmLlOHh2YCwjEhXhbaVgj+jj4woQACKNoMPtq0RNoIGBkRTtMAIXpCADUQjeFHYSFkZUSBxmqI07CsTCEcyisPhsn20zOR2yl1OaJJJxRUWyixIYEJ5myE3JJXKmCAA)):


```js
new Ractive({
  el: 'body',
  template: `
    <ul>
      {{#each Array(3)}}
        <li>
          <foo class="blue" on-bar="@global.alert('hey' + @index)">num #{{@index}}</foo>
        </li>
      {{/each}}
    </ul>
  `
})
```

### 2. Create a synchronizer proxy

1. Rename your component with `ASYNC` postfix
2. Create a synchronizer proxy with your original component's name
3. Set `@shared.deps._all` to `true` and see your synchronizer macro works correctly.

[Playground](https://ractive.js.org/playground/?env=docs#N4IgFiBcoE5SBTAJgcwSAvgGhAZ3gEoCGAxgC4CWAbggHQkD2AtgA4MB2C7ZutAZgwYBBAMoBNAHIBhAAQBeGcXLU6CAB5kuSABTAAOuz1lNrADZFNkGQAMDRowB4ARgFdjHGRwC0JUxRIA1nJ6IE5EMCEyvkS4uMEgMMgywMDRsRgYIQB8KQCeFAimSBkOAPSu7uxZdmS27BgAlADcduxKlDS0LOGURKa8AgzyiqQddEykMAza2mBE7EimCFgyFmQwuA3yWckGMlEcuGSeTgBWw-rs+-sMTrgIMDQbVgDaALpYe9cuLEgWCNo1hstsAZHMFktaPcyNoAOQAAVMDBIfVhKyBuBWoKQCAQLCs6xcCBkjSaJM+V2umnCSAYAHd2NoQV9ridTrRbvdHg8BgwYABRUhgbSebaeejzEiFJkyZosklfDAtQyGMhUcKeGAUFAAFQQZn+w3BizoJhY5k0ZJqpVKMiELBYWjt4mkMjYRz4FDUMjIQzIYGJjFYHC4x3YRCYCBqfO1eoNmloxIA1ApYaJJFJYTUcUtNJrY-rzf8ujV1TB8ygLlRIAAWFZkSAvGO6wsWhAfGQIaAZVo3M4cu4PJ68FguXDC42QzlDgEI8fhZC0HEsXgAfT6pjRMj4LnYyg42nVpgal32RgofEPfRPX3s-vmJqhCDIcaLmm0zbllKMGE7-WJp4yHeRiTnQ0Kvm22jWA4LBZAA6sSC7bs+JBgBQ7CVkGbCcNw26CGUsHWA0t5kJklKNMR36qokZAuDAVy3KcyqNK0BicHSIzKDQug1IUViwk4DBILkaI1GabZWHUjguKY1SqkYKQAMQIEKdowDARC5NoADMDQ9vJZCOH4cnAYZZAOIMUTmLE8ROKYRKRN4YQwPE8IoEiYSmLQfQPDCsIBiJMhJjI8LoTiajESAJlmaZ7AuEwMiKSkoULOo+mmY4pSDNFd5lMZNQKcApQqah6XmaUMnRdYFJGBwWG5l2267vujI3gZ-oULw0JwvC86JEgS54rgW7AOupimASMBEtgyQ4nik3TZRP4GI0mBAA)

```js
Ractive.partials.foo = Ractive.macro((handle, attrs) => {
  const obj = {
    observers: [],
    update(attrs) { handle.set('@local', attrs, { deep: true }); },
    teardown() {
      obj.observers.forEach( o => o.cancel() );
    }
  };

  var origTemplate = handle.template;
  // Append ASYNC postfix to the component name
  origTemplate.e += 'ASYNC'
  delete origTemplate.p
  var orig = {v:4, t:[origTemplate], e:{}}

  obj.observers.push(handle.observe('@shared.deps._all', function(val){
    if(val){
      handle.setTemplate(orig);
    } else {
      handle.setTemplate(`<p>We are fetching component foo</p>`)
    }
  }))
  return obj;
})
```

### 3. Load your component asynchronously

1. Load your `fooASYNC` component any time (preferably after `Ractive.oncomplete`) by any transport (XHR, uploading, websockets, etc.) you like
2. Set `@shared.deps._all` to `true` when your ASYNC component is available.

[Playground](https://ractive.js.org/playground/?env=docs#N4IgFiBcoE5SBTAJgcwSAvgGhAZ3rgDYIIAOABALzkBmArgHYDGALgJYD2DAFALa5ZaASmDkYCFnRgNyuCQBU2vBBzotuNQfyHkMAHQYGASgENWbAG4IAdKRMx2Jwrms0OHKuVPmr13mZgObm4wEwYkYkETFhYYXB1KAD5yYANyciYuXBZyDgAjACtPVJl03Ly5GCs4yHIAbQBdLDSyulIkaIRuaNj4lPJQ8OJrOXUAcgABQg4mJzGomLjBUSQSUlrYugRdIQBuXWbS9JYEeyQOAHceHRKysvyC63zK6pc3GABRMzBuXKpkjjWWbMBCEbg6PYtdL6UoYXYGBEsCz2XIwNgoeQIXikQidTyDCI2E7Y3EnfaIgD0FPIAEFSKQEOFaQBlACaADkAMLkUgcbI0NgAD3ILA8LDA20y2K4jJyDBMykRHDRGKxOM61m2AGpqGMaWyuWNEatiCdUejMSSNaREciYOaUMULJAACyCFiQOrKi1q0kIJrkBDQDAwloPJ4VBBVKMuUh0XA-AnDZ5RqzcSYJ+zIayrUguAD6TkI81ojHMXG4yMIIhaenYNErThrpTrdaTNlGlvVJ243pQkJbLBh0KEQlrhnFYUJIwUvs63AABoi6wAeUiJADq2yztAkTDAbAYjqlvIYsto7hXFPXiIXY4n4kk0nKBXhDAw94RDCp5AAYmw4hycVJQ4aUzwYHIFzcDgF3INhcHIVYBTPJByBMBCTFkABPZgMlA09ZWsch5AlBhBDYHJ4PIAwf0yBhqhOVDRTQ3AcKYXIzyIgwzwuLwzHYNMSjrUFajGPIOCQLD5kRYluyDcglwnFc6EIRJlxYYBgAAYlOfdaRgGATCw7gAGYhBDdTV0INg1InVsWFXaCMlxXBcEoPQQDyQgtg8jiAFo8nsdyQAmFBpkCwhrCcKNxglKTyC1cgJkPVZBTHEBbPsrKWAYOheHILTNOS8IEEFCy7Icyqr2gzLKtXClrNqutNIpXSwHK+qVNqhdDjrLgT1NeT6GYdgK2beyiDWbgAEYAFYAAZ5sEcF-hSSyWG8ASbBPGUILedx9Q5blqE2ywbFKk5wm4IS6sq2S-VqRTsvslc8jUUUZC4PymGspgAGtgsCmBfJ+9C3I88RUM00HXIsjLNKwthQSQEMrzemIuCa26ntuj832y8V4JncYJkzSGczIXAS2AQtCEIDYYC2PH1I-L86xhD9MCAA)
