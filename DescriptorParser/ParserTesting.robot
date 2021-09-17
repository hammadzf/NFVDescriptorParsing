*** Settings ***
Resource    variables.txt
Library     Process
Library     OperatingSystem
Library     BuiltIn
Library     Collections
Library     String
#Variables    descriptors/SOL001/VNFD/reference_tst010_vnf_b_2vdu_SOL001.yaml
Variables    descriptors/SOL001/VNFD/vnfd_SOL001.yaml
Variables    descriptors/SOL006/VNFD/reference_tst010_vnf_b_2vdu_SOL006.yaml
Variables    descriptors/SOL001/NSD/reference_tst010_nsd_simple_a_b_SOL001.yaml

*** Test Cases ***
PARSE the descriptor file correctly
    [Documentation]    Test ID: 1.1.1
    ...    Test title: PARSE the descriptor file correctly
    ...    Test objective: The objective is to check if the SOL001 descriptor file is parsed correctly.
    ...    Pre-condition: SOL001 or SOL006 descriptor YAML file is available.
    ...    Post-condition: Values from the descriptor files are stored in suite variables.
    PARSE the Descriptor File

Match the Response attributes with parsed data SOL006
    [Documentation]    Test ID: 1.1.2
    ...    Test title: Match the Response attributes with parsed data SOL006
    ...    Test objective: The objective is to check if the Response body attributes match with the information in SOL006 descriptor file.
    ...    Pre-condition: Either SOL001 or SOL006 descriptor YAML file has been parsed.
    ...    Post-condition:
    Match the Response Attributes with Descriptors SOL006

Match the Response attributes with parsed data SOL001
    [Documentation]    Test ID: 1.1.3
    ...    Test title: Match the Response attributes with parsed data SOL001
    ...    Test objective: The objective is to check if the Response body attributes match with the information in SOL001 descriptor file.
    ...    Pre-condition: Either SOL001 or SOL006 descriptor YAML file has been parsed.
    ...    Post-condition:
    Match the Response Attributes with Descriptors SOL001
    
*** Keywords ***
PARSE the Descriptor File
    Run Keyword If  '${descriptorType}'=='SOL001'    Fetch Information from SOL001 descriptor file    ELSE    Fetch Information from SOL006 descriptor file
    
Fetch Information from SOL001 descriptor file
    @{VDU_labels}=    Create List
    @{VNF_labels}=    Create List
    @{VirtualLink_labels}=    Create List
    @{CP_labels}=    Create List
    @{Storage_labels}=    Create List
    FOR    ${key}    IN    @{node_types.keys()}
        ${node_type}=    Get Variable Value    ${node_types['${key}']['derived_from']}
        ${is_VNF}=    Run Keyword And Return Status    Should Be Equal As Strings    ${node_type}    ${tosca_type_VNF}
        Run Keyword If    ${is_VNF}    Set Global Variable    ${tosca_type_derived_from_VNF}    ${key}
    END  
    ${derived_type_is_used}=    Run Keyword And Return Status    Should not be empty    ${tosca_type_derived_from_VNF}
    Run Keyword If    ${derived_type_is_used}    Set Global Variable    ${tosca_type_VNF}    ${tosca_type_derived_from_VNF}              
    FOR    ${key}    IN    @{topology_template.node_templates.keys()} 
        ${key_type}=    Get Variable Value    ${topology_template.node_templates['${key}'].type}
        ${VDU_check}=    Run Keyword And Return Status    Should Be Equal As Strings    ${key_type}   ${tosca_type_VDU_compute}
        ${VNF_check}=    Run Keyword And Return Status    Should Be Equal As Strings    ${key_type}    ${tosca_type_VNF}
        ${Link_check}=    Run Keyword And Return Status    Should Be Equal As Strings    ${key_type}    ${tosca_type_virtual_link}
        ${VDUcp_check}=    Run Keyword And Return Status    Should Be Equal As Strings    ${key_type}    ${tosca_type_VDU_cp}
        ${Storage_check}=    Run Keyword And Return Status    Should Be Equal As Strings    ${key_type}    ${tosca_type_storage}
        Run Keyword If    ${VDU_check}    Append To List    ${VDU_labels}    ${key}
        Run Keyword If    ${VNF_check}    Append To List    ${VNF_labels}    ${key}
        Run Keyword If    ${VNF_check}    Get VNF Attributes from SOL001    ${key}            
        Run Keyword If    ${Link_check}    Append To List    ${VirtualLink_labels}    ${key}
        Run Keyword If    ${VDUcp_check}    Append To List    ${CP_labels}    ${key}
        Run Keyword If    ${Storage_check}    Append To List    ${Storage_labels}    ${key}
    END
    Set Global Variable    @{VDU_IDs}    @{VDU_labels}
    Set Global Variable    @{VNF_IDs}    @{VNF_labels}
    Set Global Variable    @{VirtualLink_IDs}    @{VirtualLink_labels}
    Set Global Variable    @{CP_IDs}    @{CP_labels}
    Set Global Variable    @{Storage_IDs}    @{Storage_labels}

Get VNF Attributes from SOL001
    [Arguments]    ${VNF_label}
    ${descriptor_id}=    Get Variable Value    ${topology_template.node_templates['${VNF_label}'].properties.descriptor_id}
    ${provider}=    Get Variable Value    ${topology_template.node_templates['${VNF_label}'].properties.provider}
    ${product_name}=    Get Variable Value    ${topology_template.node_templates['${VNF_label}'].properties.product_name}
    ${software_version}=    Get Variable Value    ${topology_template.node_templates['${VNF_label}'].properties.software_version}
    ${descriptor_version}=    Get Variable Value    ${topology_template.node_templates['${VNF_label}'].properties.descriptor_version}
    
    Set Global Variable    ${Descriptor_ID}    ${descriptor_id}
    Set Global Variable    ${Provider}    ${provider}
    Set Global Variable    ${Product_Name}    ${product_name}
    Set Global Variable    ${Software_Version}    ${software_version}
    Set Global Variable    ${Descriptor_Version}    ${descriptor_version}

Fetch Information from SOL006 descriptor file
    ${descriptor_id}=    Get Variable Value    ${nfv.vnfd[0].id}
    ${provider}=    Get Variable Value    ${nfv.vnfd[0].provider}
    ${product_name}=    Get Variable Value    ${nfv.vnfd[0]['product-name']}
    ${software_version}=    Get Variable Value    ${nfv.vnfd[0]['software-version']}
    ${descriptor_version}=    Get Variable Value    ${nfv.vnfd[0].version}    
    ${VDUcount}=    Get Length    ${nfv.vnfd[0].vdu}
    ${extCP_count}=    Get Length    ${nfv.vnfd[0]['ext-cpd']}
    ${virtualLink_count}=    Get length    ${nfv.vnfd[0]['int-virtual-link-desc']}
    ${instantiation_levels}=    Get Length    ${nfv.vnfd[0].df['instantiation-level']}    
    FOR    ${key}    IN    @{nfv.vnfd[0].keys()}
        ${VDU_check}=    Run Keyword And Return Status    Should Be Equal As Strings    ${key}    vdu
        Run Keyword If    ${VDU_check}    Get VDU IDs    ${VDUcount}
        ${extCP_check}=    Run Keyword And Return Status    Should Be Equal As Strings    ${key}    ext-cpd
        Run Keyword If    ${extCP_check}    Get External CP IDs    ${extCP_count}
        ${virtualLink_check}=    Run Keyword And Return Status    Should Be Equal As Strings    ${key}    int-virtual-link-desc
        Run Keyword If    ${virtualLink_check}    Get Virtual Link IDs   ${virtualLink_count}    
        ${DF_check}=    Run Keyword And Return Status    Should Be Equal As Strings    ${key}    df
        Run Keyword If    ${DF_check}    Get Instantiation Levels    ${instantiation_levels}    
    END
    Set Global Variable    ${Descriptor_ID}    ${descriptor_id}
    Set Global Variable    ${Provider}    ${provider}
    Set Global Variable    ${Product_Name}    ${product_name}
    Set Global Variable    ${Software_Version}    ${software_version}
    Set Global Variable    ${Descriptor_Version}    ${descriptor_version}

Get VDU IDs
    [Arguments]    ${count}    
    @{VDU_labels}=    Create List
    ${Storage_labels}=    Create List
    FOR    ${i}    IN RANGE    ${count}
        Append To List    ${VDU_labels}    ${nfv.vnfd[0].vdu[${i}]['id']}
        Append To List    ${Storage_labels}    ${nfv.vnfd[0].vdu[${i}]['virtual-storage-desc']} 
        Get Internal CPs for each VDU    ${i}   
    END
    Set Global Variable    ${VDU_IDs}    ${VDU_labels}
    Set Global Variable    ${Storage_IDs}    ${Storage_labels}
            
Get Internal CPs for each VDU
    [Arguments]    ${vdu}
    ${count}=    Get Length    ${nfv.vnfd[0].vdu[${vdu}]['int-cpd']}    
    ${internal_CPs}=    Create List
    FOR    ${i}    IN RANGE    ${count}
        Append To List    ${internal_CPs}    ${nfv.vnfd[0].vdu[${vdu}]['int-cpd'][${i}]['id']} 
    END
    Set Global Variable    ${internalCP_IDs}    ${internal_CPs}
    
Get External CP IDs
    [Arguments]    ${count}    
    @{external_CPs}=    Create List
    FOR    ${i}    IN RANGE    ${count}
        Append To List    ${external_CPs}    ${nfv.vnfd[0]['ext-cpd'][${i}]['id']} 
    END
    Set Global Variable    ${externalCP_IDs}    ${external_CPs}

Get Virtual Link IDs
    [Arguments]    ${count}    
    ${VirtualLink_labels}=    Create List
    FOR    ${i}    IN RANGE    ${count}
        Append To List    ${VirtualLink_labels}    ${nfv.vnfd[0]['int-virtual-link-desc'][${i}]['id']} 
    END
    Set Global Variable    ${VirtualLink_IDs}    ${VirtualLink_labels}

Get Instantiation Levels
    [Arguments]    ${count}
    @{Instantiation_Levels}=    Create List
    FOR    ${i}    IN RANGE    ${count}
        Append To List    ${Instantiation_Levels}    ${nfv.vnfd[0].df['instantiation-level'][${i}]['id']} 
    END
    Set Global Variable    ${InstantiationLevel_IDs}    ${Instantiation_Levels}

Match the Response Attributes with Descriptors SOL006
    #VNF CHECK
    Should Be Equal As Strings    ${Descriptor_ID}    ${Response_VNFId}    
    #Product-Name check
    Should Be Equal As Strings    ${Product_Name}    ${Response_ProductName}   
    Should Be Equal As Strings    ${Software_Version}    ${Response_SoftwareVersion}     
    #List Should Contain Value    ${VNF_IDs}    ${Response_VNFId}
    #VDU CHECK
    List Should Contain Value    ${VDU_IDs}    ${Response_vduId}
    #Int-CP CHECK
    List Should Contain Value    ${internalCP_IDs}    ${Response_intCP}
    #Ext-CP CHECK
    List Should Contain Value    ${externalCP_IDs}    ${Response_extCP}
    #Virtual Link Check
    List Should Contain Value    ${VirtualLink_IDs}    ${Response_virtualLink}
    #Virtual Storage Check
    List Should Contain value    ${Storage_IDs}    ${Response_Storage}
    #Instantiation Level Check
    List Should Contain value    ${InstantiationLevel_IDs}    ${Response_InstantiationLevel}
    
Match the Response Attributes with Descriptors SOL001
    #VNF CHECK
    Should Be Equal As Strings    ${Descriptor_ID}    ${Response_vnfd_id_SOL1}    
    #Product-Name check
    Should Be Equal As Strings    ${Product_Name}    ${Response_ProductNameS001}   
    Should Be Equal As Strings    ${Software_Version}    ${Response_SoftwareVersionS001}     
    #List Should Contain Value    ${VNF_IDs}    ${Response_VNFId}
    #VDU CHECK
    List Should Contain Value    ${VDU_IDs}    ${Response_vduIdS001}
    #Int-CP CHECK
    #List Should Contain Value    ${CP_IDs}    ${Response_intCPS001}
    #Ext-CP CHECK
    List Should Contain Value    ${CP_IDs}    ${Response_extCPS001}
    #Virtual Link Check
    #List Should Contain Value    ${VirtualLink_IDs}    ${Response_virtualLinkS001}
    #Virtual Storage Check
    List Should Contain value    ${Storage_IDs}    ${Response_StorageS001}