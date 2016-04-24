<?php
namespace App\Services\Validators\Auth;

use App\Services\Validators\Validator;
use App\Http\Request;

class LoginValidator extends Validator {
  public function validate(Request $request) {
    $username = $request->getApiAttribute('username');
    $password = $request->getApiAttribute('password');

    if ($username === null) {
      $this->addError('auth.usernameIsMandatory', '/data/attributes/username');
    }
  }
}