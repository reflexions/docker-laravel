<?php
namespace Reflexions\DockerLaravel;

class DockerServiceProvider extends \Illuminate\Support\ServiceProvider
{
	public function boot()
	{
		$this->publishes([
	        __DIR__.'/../../../Dockerfile' => base_path('Dockerfile'),
	        __DIR__.'/../../../docker-compose.yml' => base_path('docker-compose.yml'),
	        __DIR__.'/../../../example.env' => base_path('example.env'),
	    ]);
	}

	public function register()
    {
        
    }
}