<!DOCTYPE html>

<html>

    <head>
        <title>Sistemium login</title>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link href="../libs/bootstrap/css/bootstrap.min.css" rel="stylesheet">
		<link href="../libs/bootstrap/css/bootstrap-responsive.css" rel="stylesheet">
        
        <style>
            .button-image{
                max-height: 100px;
                max-width: 300px;
            }
            
            .lead {
                text-shadow: #FFFFFF 1px 1px 1px;
                line-height: 40px;
            }
            
            .thumbnail {
                border: 1px solid #aaa;
                -webkit-box-shadow: 0 1px 3px rgba(0, 0, 0, 0.15);
                -moz-box-shadow: 0 1px 3px rgba(0, 0, 0, 0.15);
                box-shadow: 0 1px 3px rgba(0, 0, 0, 0.15);
            }
            
            a.thumbnail:hover {
                -webkit-box-shadow: 0 1px 4px rgba(0, 105, 214, 0.3);
                -moz-box-shadow: 0 1px 4px rgba(0, 105, 214, 0.3);
                box-shadow: 0 1px 4px rgba(0, 105, 214, 0.3);
            }
			
			@font-face {
				font-family: 'Didact Gothic';
				font-style: normal;
				font-weight: 400;
				src: local('Didact Gothic'), local('DidactGothic'), url(didactgothic.woff) format('woff');
			}
        </style>
        
    </head>
    
    <body>
        
        <?php 
            $u_auth_server_url = "https://system.unact.ru/oauth/handler/auth";
            $client_id = 'st.com';
            
            $googleServiceName = "oauth.it.ggl";
            $googleClientID = "429140241854-p4gs638ghavpevaajbov3igmtlu8digk.apps.googleusercontent.com";
            
            $facebookServiceName = "oauth.it.fsb";
            $facebookClientID = "352968081491423";
            
            $vkServiceName = "vk";
            $vkClientID = "3141555";
            
            $mailruServiceName = "mailru";
            $mailruClientID = "689363";
            
            $odksServiceName = "odks";
            $odksClientID = "93366272";

            $googleRedirectURL = $u_auth_server_url . "/". $googleServiceName ."/" . $client_id;
            $facebookRedirectURL = $u_auth_server_url . "/". $facebookServiceName ."/" . $client_id;
            $vkRedirectURL = $u_auth_server_url . "/". $vkServiceName ."/" . $client_id;
            $mailruRedirectURL = $u_auth_server_url . "/". $mailruServiceName ."/" . $client_id;
            $odksRedirectURL = $u_auth_server_url . "/". $odksServiceName ."/" . $client_id;
            
            $googleAuthURL = "https://accounts.google.com/o/oauth2/auth?scope=https://www.googleapis.com/auth/userinfo.email+https://www.googleapis.com/auth/userinfo.profile&response_type=code&client_id=" . $googleClientID . "&redirect_uri=" . $googleRedirectURL;
            
            $facebookAuthURL = "https://www.facebook.com/dialog/oauth?scope=email&client_id=" . $facebookClientID . "&redirect_uri=" . $facebookRedirectURL;
            
            $vkAuthURL = "http://oauth.vk.com/authorize?scope=status&response_type=code&client_id=" . $vkClientID . "&redirect_uri=" . $vkRedirectURL;
            
            $mailruAuthURL = "https://connect.mail.ru/oauth/authorize?response_type=code&client_id=" . $mailruClientID . "&redirect_uri=" . $mailruRedirectURL;
            
            $odksAuthURL = "http://www.odnoklassniki.ru/oauth/authorize?response_type=code&client_id=" . $odksClientID . "&redirect_uri=" . $odksRedirectURL;
            
            $authError = false;
			
			@$authError = $_REQUEST["authError"];
            
            if ($authError){
            	echo "<div class='alert alert-error'>
                        <strong>Ошибка!</strong> Не удалось аутентифицировать. (" . htmlspecialchars ($authError) .
                    ")</div>";
            }
        ?>
        
        <div class = "container">
            <div class="row">
                
                <div class="span4 offset4">	
                    <ul class="thumbnails">
                        <li><p class="lead">Войти&nbsp;с&nbsp;помощью</p></li>
                        <li>
                            <a class="thumbnail btn" href="<?php echo $googleAuthURL;?>">
                                <img src="img/google-logo.png" class="img-rounded button-image">
                            </a>
                        </li>
                        <li>
                            <a class="thumbnail btn" href="<?php echo $facebookAuthURL;?>">
                                <img src="img/facebook-logo.png" class="img-rounded button-image">
                            </a>
                        </li>
                        <li>
                            <a class="thumbnail btn disabled" data-disable-href="<?php echo $vkAuthURL;?>">
                                <img src="img/vk-logo.png" class="img-rounded button-image">
                            </a>
                        </li>
                        <li>
                            <a class="thumbnail btn disabled" data-disable-href="<?php echo $mailruAuthURL;?>">
                                <img src="img/mailru-logo.png" class="img-rounded button-image">
                            </a>
                        </li>
                        <li>
                            <a class="thumbnail btn disabled" data-disable-href="<?php echo $odksAuthURL;?>">
                                <img src="img/odks-logo.png" class="img-rounded button-image">
                            </a>
                        </li>
                        <li><small>alevin.ru demo</small></li>
                    </ul>
                </div>
            </div>
        </div>
    </body>
    
</html>