*** Settings ***
Resource    variables.txt
Library     Process
Library     OperatingSystem
Library     BuiltIn
Library     Collections
Library     String
Variables    descriptors/SOL001/NSD/reference_tst010_nsd_simple_a_b_SOL001.yaml
Variables    descriptors/SOL001/VNFD/reference_tst010_vnf_b_2vdu_SOL001.yaml
#Variables    descriptors/SOL006/reference_tst010_vnf_b_2vdu_SOL006.yaml
Variables    descriptors/SOL006/NSD/reference_tst010_nsd_simple_a_b_SOL006.yaml

*** Test Cases ***
PARSE the NS descriptor file correctly
    [Documentation]    Test ID: 1.2.1
    ...    Test title: PARSE the NS descriptor file correctly
    ...    Test objective: The objective is to check if the NS descriptor file is parsed correctly.
    ...    Pre-condition: SOL001 or SOL006 descriptor YAML file is available.
    ...    Post-condition: Values from the descriptor files are stored in suite variables.
    PARSE the NS Descriptor File
    
Match the Response attributes with parsed data NSD SOL001
    [Documentation]    Test ID: 1.2.2
    ...    Test title: Match the Response attributes with parsed data NSD SOL001
    ...    Test objective: The objective is to check if the Response body attributes match with the information in SOL001 NS descriptor file.
    ...    Pre-condition: Either SOL001 or SOL006 NS descriptor YAML file has been parsed.
    ...    Post-condition:
    Match the Response Attributes with NS Descriptors SOL001

Match the Response attributes with parsed data NSD SOL006
    [Documentation]    Test ID: 1.2.3
    ...    Test title: Match the Response attributes with parsed data NSD SOL001
    ...    Test objective: The objective is to check if the Response body attributes match with the information in SOL001 NS descriptor file.
    ...    Pre-condition: Either SOL001 or SOL006 NS descriptor YAML file has been parsed.
    ...    Post-condition:
    Match the Response Attributes with NS Descriptors SOL006
    
Match the Response attributes with parsed data SOL006
    [Documentation]    Test ID: 1.2.4
    ...    Test title: Match the Response attributes with parsed data SOL006
    ...    Test objective: The objective is to check if the Response body attributes match with the information in SOL006 descriptor file.
    ...    Pre-condition: Either SOL001 or SOL006 descriptor YAML file has been parsed.
    ...    Post-condition:
    Match the Response Attributes with Descriptors SOL006

*** Keywords ***
PARSE the NS Descriptor File
    Run Keyword If  '${descriptorType}'=='SOL001'    Fetch Information from SOL001 NS descriptor file    ELSE    Fetch Information from SOL006 NS descriptor file

Fetch Information from SOL001 NS descriptor file
    @{NsVirtualLink_labels}=    Create List
    @{NsCP_labels}=    Create List
    FOR    ${key}    IN    @{topology_template.node_templates.keys()} 
        ${key_type}=    Get Variable Value    ${topology_template.node_templates.${key}.type}
        ${NS_check}=    Run Keyword And Return Status    Should Be Equal As Strings    ${key_type}   ${tosca_type_NS}
        ${NSLink_check}=    Run Keyword And Return Status    Should Be Equal As Strings    ${key_type}    ${tosca_type_NsVirtualLink}
        ${NsCP_check}=    Run Keyword And Return Status    Should Be Equal As Strings    ${key_type}    ${tosca_type_NsCP}
        Run Keyword If    ${NS_check}    Get NS Attributes from SOL001    ${key}
        Run Keyword If    ${NSLink_check}    Append To List    ${Ns_VirtualLink_labels}    ${key}
        Run Keyword If    ${NsCP_check}    Append To List    ${NsCp_labels}    ${key}        
    END
    Set Global Variable    @{NS_VirtualLink_IDs}    @{NsVirtualLink_labels}
    Set Global Variable    @{NsCP_IDs}    @{NsCP_labels}

Get NS Attributes from SOL001
    [Arguments]    ${NS_label}
    ${ns_descriptor_id}=    Get Variable Value    ${topology_template.node_templates.${NS_label}.properties.descriptorId}
    ${designer}=    Get Variable Value    ${topology_template.node_templates.${NS_label}.properties.designer}
    ${version}=    Get Variable Value    ${topology_template.node_templates.${NS_label}.properties.version}
    ${name}=    Get Variable Value    ${topology_template.node_templates.${NS_label}.properties.name}
    ${invariantId}=    Get Variable Value    ${topology_template.node_templates.${NS_label}.properties.invariantId}
    
    Set Global Variable    ${NS_DescriptorID}    ${ns_descriptor_id}
    Set Global Variable    ${Designer}    ${designer}
    Set Global Variable    ${NS_Version}    ${version}
    Set Global Variable    ${NS_Name}    ${name}
    Set Global Variable    ${NS_InvariantID}    ${invariantId}

Fetch Information from SOL006 NS descriptor file
    ${nsd_id}=    Get Variable Value    ${nfv.nsd[0].id}
    ${VNFcount}=    Get Length    ${nfv.vnfd}
    ${SAPcount}=    Get Length    ${nfv.nsd[0].sapd}
    ${NSvirtualLinkCount}=    Get Length    ${nfv.nsd[0]['virtual-link-desc']}
    FOR    ${key}    IN    @{nfv.keys()}
        ${VNFD_check}=    Run Keyword And Return Status    Should Be Equal As Strings    ${key}    vnfd
        ${NSD_check}=    Run Keyword And Return Status    Should Be Equal As Strings    ${key}    nsd
        Run Keyword If    ${VNFD_check}    Get External CPs for each VNF    ${VNFcount}
        Run Keyword If    ${VNFD_check}    Fetch Information from SOL006 descriptor file
        Run Keyword If    ${NSD_check}    Get SAP IDs    ${SAPcount}
        Run Keyword If    ${NSD_check}    Get NS Virtual Link IDs    ${NSvirtualLinkCount}

    END
    Set Global Variable    ${NS_DescriptorID}    ${nsd_id}

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
    @{VirtualLink_labels}=    Create List
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

Get External CPs for each VNF
    [Arguments]    ${vnf}
    FOR    ${i}    IN RANGE    ${vnf}
        Get Ext CP IDs    ${i}
    END

Get Ext CP IDs
    [Arguments]    ${vnf}
    @{extCP_labels}=    Create List
    ${count}=    Get Length    ${nfv.vnfd[${vnf}]['ext-cpd']}    
    FOR    ${i}    IN RANGE    ${count}
        Append To List    ${extCP_labels}    ${nfv.vnfd[${vnf}]['ext-cpd'][${i}]['id']} 
    END
    Set Global Variable    ${NsCP_IDs}    ${extCP_labels}
   
Get SAP IDs
    [Arguments]    ${count}
    @{SAPlabels}=    Create List
    FOR    ${i}    IN RANGE    ${count}
        Append To List    ${SAPlabels}    ${nfv.nsd[0].sapd[${i}]['id']}
    END
    Set Global Variable    ${SAP_IDs}    ${SAPlabels}
    
Get NS Virtual Link IDs
    [Arguments]    ${count}
    @{NsVirtualLink_labels}=    Create List
    FOR    ${i}    IN RANGE    ${count}
        Append To List    ${NsVirtualLink_labels}    ${nfv.nsd[0]['virtual-link-desc'][${i}]['id']}
    END
    Set Global Variable    ${NS_VirtualLink_IDs}    ${NsVirtualLink_labels}
    
Match the Response Attributes with NS Descriptors SOL001
    Should Be Equal As Strings    ${NSDescriptor_ID}    ${Response_NSIdS001}    
    Should Be Equal As Strings    ${NS_Name}    ${Response_NSnameS001}   
    Should Be Equal As Strings    ${NS_Version}    ${Response_NsVersion}
    Should Be Equal As Strings    ${NS_InvariantID}    ${Response_NSInvariantIDS001}
    Should Be Equal As Strings    ${Designer}    ${Response_NSdesignerS001}      
    
Match the Response Attributes with NS Descriptors SOL006
    Should Be Equal As Strings    ${NSDescriptor_ID}    ${Response_NSIdSol6}    
    #List Should Contain Value    ${NsCP_IDs}    ${Response_extCpSol6}
    List Should Contain value    ${SAP_IDs}    ${Response_SapIDSol6}
    List Should Contain value    ${NS_VirtualLink_IDs}    ${Response_NS_VL_S6}

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
    

