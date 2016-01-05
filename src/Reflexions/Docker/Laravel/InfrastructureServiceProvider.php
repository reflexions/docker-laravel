<?php
namespace Reflexions\Docker\Laravel;

class InfrastructureServiceProvider extends \Illuminate\Support\ServiceProvider
{
	public function boot()
	{
		$this->publishes([
	        __DIR__.'/../../../../Dockerfile' => base_path('Dockerfile'),
            __DIR__.'/../../../../setup.sh' => base_path('resources/content-infrastructure/setup.sh'),
            __DIR__.'/../../../../start.sh' => base_path('resources/content-infrastructure/start.sh'),
	    ]);
	}

	public function register()
    {
        
    }
}