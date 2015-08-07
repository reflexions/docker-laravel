<?php
namespace Reflexions\Content\Infrastructure;

class InfrastructureServiceProvider extends \Illuminate\Support\ServiceProvider
{
	public function boot()
	{
		$this->publishes([
	        __DIR__.'/../../../../Dockerfile' => base_path('Dockerfile'),
	    ]);
	}

	public function register()
    {
        
    }
}