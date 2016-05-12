<?php

namespace App\Services\Validators\Application;


use App\Http\Request;
use App\Services\Validators\Validator;

class ApplicationAuthenticationValidator extends Validator {

  public function validate(Request $request) {
    $this->validateAuthenticationScheme($request);
    $this->validateAuthenticationFunction($request);
    $this->validateLoginPageTemplate($request);
  }

  protected  function validateAuthenticationScheme(Request $request) {
    $authenticationScheme = trim($request->getApiAttribute('authenticationScheme', ''));
    if (!in_array($authenticationScheme, ['USER_FUNCTION', 'NO_AUTHENTICATION'])) {
      $this->addError('application.suchAuthenticationSchemeDoesNotExist', '/data/attributes/authenticationScheme');
    }
  }

  protected function validateAuthenticationFunction(Request $request) {
    $authenticationFunction = $request->getApiAttribute('authenticationFunction', '');

    if ($this->authenticationSchemeIsUserFunction($request) &&
        (trim($authenticationFunction['database']) === '' ||
        trim($authenticationFunction['schema']) === '' ||
        trim($authenticationFunction['function']) === '')
    ) {
      $this->addError('application.suchFunctionDoesNotExist', '/data/attributes/authenticationFunction');
    }
  }

  protected function validateLoginPageTemplate(Request $request) {
    $loginPageTemplate = $request->getApiAttribute('loginPageTemplate');
    if ($this->authenticationSchemeIsUserFunction($request) && !is_int($loginPageTemplate)) {
      $this->addError('application.suchLoginPageTemplateDoesNotExist', '/data/attributes/loginPageTemplate');
    }
  }

  protected function authenticationSchemeIsUserFunction($request) {
    return $request->getApiAttribute('authenticationScheme') === 'USER_FUNCTION';
  }
}