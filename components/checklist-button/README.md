items = 
  * id: ...
    name: ...
    checked: true/false 
  ... 
  
  
Example usage: 

    Example Data: 
    
        items:
            * id: 1
              name: "rengine baktın mı "
              checked: yes
            * id: 2
              name: "kokusu uygun mu "
            * id: 3
              name: "ambalajı açılmış mı?"
            * id: 4
              name: "seri numarası var mı "
            * id: 5
              name: "hoşuna gitti mi"    

    JADE: 

        checklist-button(
            items="{{ xitems }}" 
            on-success="checklistSucceeded" 
            on-fail="checklistFailed" 
            value="{{ xitems[0] }}"
            success-text="Mal Kabul Tamam"
            fail-text="Mal Kabul Reddedildi"
            )
        
    LS: 
    
    
        checklist-succeeded: (e, value) ->
            e.component.fire \state, \doing
            console.log "checklist succeeded: ", value
            <- sleep 2000ms
            e.component.fire \state, \done...

        checklist-failed: (e, value) ->
            e.component.fire \state, \doing
            console.log "checklist failed: ", value 
            <- sleep 2000ms
            e.component.fire \state, \done...


  
