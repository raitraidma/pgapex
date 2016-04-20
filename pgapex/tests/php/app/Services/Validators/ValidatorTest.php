<?php

namespace Tests\App\Services\Validators\Auth;

use App\Http\Request;
use App\Services\Validators\Validator;

class ValidatorTest extends \TestCase
{
  public function testAttachErrorsToResponse() {
    $validator = new ValidatorImpl();
    $validator->addError('detail-1-1', 'pointer-1');
    $validator->addError('detail-1-2', 'pointer-1');
    $validator->addError('detail-2-1', 'pointer-2');

    $response = $this->mock('App\Http\Response');
    $response->shouldReceive('addApiErrorWithPointer')->with('detail-1-1', 'pointer-1');
    $response->shouldReceive('addApiErrorWithPointer')->with('detail-1-2', 'pointer-1');
    $response->shouldReceive('addApiErrorWithPointer')->with('detail-2-1', 'pointer-2');

    $validator->attachErrorsToResponse($response);
  }
}

class ValidatorImpl extends Validator {
  public function validate(Request $request) {}
}