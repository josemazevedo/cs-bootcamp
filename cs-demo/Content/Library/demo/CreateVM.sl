namespace: demo
flow:
  name: CreateVM
  inputs:
    - host: 10.0.46.10
    - username: "Capa1\\1302-capa1user"
    - password: Automation123
    - datacenter: Capa1 Datacenter
    - image: Ubuntu
    - folder: Students/JAzevedo
    - prefix_list: '1-,2-,3-'
  workflow:
    - uuid:
        do:
          io.cloudslang.demo.uuid:
            - input_0: null
        publish:
          - uuid: '${"jma-"+uuid}'
        navigate:
          - SUCCESS: substring
    - substring:
        do:
          io.cloudslang.base.strings.substring:
            - origin_string: '${uuid}'
            - end_index: '13'
        publish:
          - id: '${new_string}'
        navigate:
          - SUCCESS: clone_vm
          - FAILURE: FAILURE
    - clone_vm:
        parallel_loop:
          for: prefix in prefix_list
          do:
            io.cloudslang.vmware.vcenter.vm.clone_vm:
              - host: '${host}'
              - user: '${username}'
              - password:
                  value: '${password}'
                  sensitive: true
              - vm_source_identifier: name
              - vm_source: '${image}'
              - datacenter: '${datacenter}'
              - vm_name: '${prefix+uuid}'
              - image: null
              - folder: null
              - prefix_list: null
              - vm_folder: '${folder}'
              - mark_as_template: 'false'
              - trust_all_roots: 'true'
              - x_509_hostname_verifier: allow_all
        navigate:
          - SUCCESS: power_on_vm
          - FAILURE: FAILURE
    - power_on_vm:
        parallel_loop:
          for: prefix in prefix_list
          do:
            io.cloudslang.vmware.vcenter.power_on_vm:
              - host: '${host}'
              - user: '${username}'
              - password:
                  value: '${password}'
                  sensitive: true
              - vm_identifier: name
              - vm_name: '${prefix+id}'
              - trust_all_roots: 'true'
              - x_509_hostname_verifier: allow_all
        navigate:
          - SUCCESS: wait_for_vm_info
          - FAILURE: FAILURE
    - wait_for_vm_info:
        parallel_loop:
          for: prefix in prefix_list
          do:
            io.cloudslang.vmware.vcenter.util.wait_for_vm_info:
              - host: '${host}'
              - user: '${username}'
              - password:
                  value: '${password}'
                  sensitive: true
              - vm_identifier: name
              - vm_name: '${prefix+uuid}'
              - datacenter: '${datacenter}'
        publish:
          - ip_list: '${str([str(x["ip"]) for x in branches_context])}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: FAILURE
  outputs:
    - ip_list: '${ip_list}'
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      uuid:
        x: 104
        y: 74
      substring:
        x: 286
        y: 77
        navigate:
          c3286894-e964-0ceb-94a1-f5e0bf870ca7:
            targetId: 8737c766-b87f-ea9d-1adf-f39e6c9e8290
            port: FAILURE
      clone_vm:
        x: 448
        y: 84
        navigate:
          14f87b97-023b-e272-4cb9-3defec541a3b:
            targetId: 8737c766-b87f-ea9d-1adf-f39e6c9e8290
            port: FAILURE
      power_on_vm:
        x: 647
        y: 82
        navigate:
          f4d7467d-2131-7118-4b51-b850ba38084a:
            targetId: 8737c766-b87f-ea9d-1adf-f39e6c9e8290
            port: FAILURE
      wait_for_vm_info:
        x: 640
        y: 274
        navigate:
          234daa44-d01f-c0ea-4a62-086fbb74c868:
            targetId: 8737c766-b87f-ea9d-1adf-f39e6c9e8290
            port: FAILURE
          ffc1d867-87d9-690d-a76b-92384f18daee:
            targetId: 07be0062-5822-727f-8157-724467097f64
            port: SUCCESS
    results:
      SUCCESS:
        07be0062-5822-727f-8157-724467097f64:
          x: 829
          y: 277
      FAILURE:
        8737c766-b87f-ea9d-1adf-f39e6c9e8290:
          x: 439
          y: 288
