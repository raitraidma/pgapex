<?php

namespace Tests\App\Http;

use App\Http\Request;

class RequestTest extends \TestCase
{
  public function testGetApiAttributeFromParsedBody() {
    $uriInterface = $this->spy('Psr\Http\Message\UriInterface');
    $headersInterface = $this->spy('Slim\Interfaces\Http\HeadersInterface');
    $streamInterface = $this->spy('Psr\Http\Message\StreamInterface');

    $attributeName = 'attribute';
    $request = [];
    $request['data']['attributes'][$attributeName] = 'value';
    $result = $this->invokeObjectMethod(new Request(null, $uriInterface, $headersInterface, [], [], $streamInterface, []),
                                        'getApiAttributeFromParsedBody',
                                        [$request, $attributeName, null]);
    $this->assertEquals('value', $result);
  }

  public function testGetApiAttributeFromParsedBodyReturnsDefaultValueWhenAttributeDoesNotExist() {
    $uriInterface = $this->spy('Psr\Http\Message\UriInterface');
    $headersInterface = $this->spy('Slim\Interfaces\Http\HeadersInterface');
    $streamInterface = $this->spy('Psr\Http\Message\StreamInterface');

    $attributeName = 'attribute';
    $request = [];
    $request['data']['attributes'] = [];
    $result = $this->invokeObjectMethod(new Request(null, $uriInterface, $headersInterface, [], [], $streamInterface, []),
                                        'getApiAttributeFromParsedBody',
                                        [$request, $attributeName, 'default-value']);
    $this->assertEquals('default-value', $result);
  }
}