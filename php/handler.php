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
        
        var_dump($ret);
        curl_close($ch);
        
        return $ret;
        
    }
    ///////////////////////
    function asaReadAnswer($answer) {
        
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
        $urlA = array();
        $u = $_SERVER[SCRIPT_NAME];
        $u = substr($u, strpos($u,'/handler/'));

        foreach (explode('/', $u) as $url) 
            $urlA['url'.(++$i?$i:'0')] = $url;
            
        $service = $urlA['url3'];
            
        if ($service == 'auth') {
            
            $parms['e_service'] = $urlA['url4'];
            $parms['client_id'] = $urlA['url5'];
            $parms['e_code'] = $_REQUEST['code'];
            
        } elseif ($service == 'token') {
            
        }
    }
    
    asaPost ($service, $parms);
    
    
?>