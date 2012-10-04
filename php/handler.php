<?php
    ////////////////////////
    function dumpNice ($array) {
        foreach ($array as $key=>$value)
            print $key .' = '. $value."<br/>";
    }    
    ////////////////////////
    function asaPost ($service, $postDataArray) {
        
        $ch = curl_init("https://hqvsrv58/iExp/UOAuth/".$service);
    
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
        curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        
        foreach ($postDataArray as $key=>$value)
            $data .= ($data?'&':'').$key .'='. $value;
        
        curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
    
        $ret = curl_exec($ch);
        
        curl_close($ch);
        
        return $ret;
        
    }
    ///////////////////////
    function asaReadResponse($response) {
        
        $xml = new DOMDocument();
        $ret = array();
        
        $xml -> loadXML($response);
        
        foreach ($xml -> documentElement -> childNodes as $currentNode)
            if ($currentNode -> nodeType == XML_ELEMENT_NODE) $ret[$currentNode -> nodeName] = $currentNode -> nodeValue;
        
        return $ret;
    }
    ////////////////////////
    //print '<br/>$_SERVER:<br/><br/>';dumpNice ($_SERVER);
    //print '<br/>$_REQUEST:<br/><br/>';dumpNice ($_REQUEST);
    
    $parms = array();

    if ($_SERVER[TERM_PROGRAM]) {
        print 'terminal';
    }
    else {
        $urlPathParts= array();
        $u = $_SERVER[SCRIPT_NAME];
        $u = substr($u, strpos($u,'/handler/'));

        foreach (explode('/', $u) as $urlPart) 
            array_push ($urlPathParts, $urlPart);
    
        if (count($urlPathParts) < 5) {
            print 'Wrong URL';
            return;
        }
        
        $service = $urlPathParts[2];
            
         switch ($service) {
            case 'auth':
            
                $parms['e_service'] = $urlPathParts[3];
                $parms['client_id'] = $urlPathParts[4];
                $parms['e_code'] = $_REQUEST['code'];
                
            case 'token':
            
        }
    }
    
    $asaResponse = asaPost($service, $parms);
    
    $asaResponseArray = asaReadResponse($asaResponse);

    switch ($service) {
        case 'auth':
            if(!$parms['client_id']) {
                print 'Wrong client_id';
                return;
            }
            $redirectUrl = $asaResponseArray['redirect-url'].($asaResponseArray['auth-code']
                                                              ?'?code='.$asaResponseArray['auth-code']
                                                              :'?error='.$asaResponseArray['error']);
            header('Location: '.$redirectUrl, true, 302);
            return;
        
        case 'token':
    }
    
    
?>