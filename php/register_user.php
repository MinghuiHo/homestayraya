<?php
error_reporting(0);

if (!isset($_POST['register'])) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die();
}

include_once("dbconnect.php");
$name = $_POST['name'];
$email = $_POST['email'];
$phone = $_POST['phone'];
$password = sha1($_POST['pass']);
$otp = rand(10000,99999);
$address = "na";

$sqlregister = "INSERT INTO tbl_users(user_name, user_email, user_phone, user_pass, user_otp, user_address) VALUES ('$name','$email','$phone','$password','$otp','$address')";

try {
    if ($conn->query($sqlregister) === TRUE) {
        $response = array('status' => 'success', 'data' => null);
        sendJsonResponse($response);
    }else{
        $response = array('status' => 'failed', 'data' => null);
        sendJsonResponse($response);
    }
}
catch(Exception $e) {
  $response = array('status' => 'failed', 'data' => null);
  sendJsonResponse($response);
}
$conn->close();

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}

?>