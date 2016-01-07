<?php
namespace Reflexions\DockerLaravel;

class DockerApplication extends \Illuminate\Foundation\Application
{
	/**
     * Get the path to the storage directory.
     *
     * @return string
     */
    public function storagePath()
    {
    	return $this->storagePath ?: env('LARAVEL_STORAGE_PATH', $this->basePath.DIRECTORY_SEPARATOR.'storage');
    }

    public function bootstrapCachePath()
    {
    	return env('LARAVEL_BOOTSTRAP_CACHE_PATH', $this->basePath().'/bootstrap/cache');
    }

    /**
     * Get the path to the configuration cache file.
     *
     * @return string
     */
    public function getCachedConfigPath()
    {
    	return $this->bootstrapCachePath().'/config.php';
    }

    /**
     * Get the path to the routes cache file.
     *
     * @return string
     */
    public function getCachedRoutesPath()
    {
    	return $this->bootstrapCachePath().'/routes.php';
    }

    /**
     * Get the path to the cached "compiled.php" file.
     *
     * @return string
     */
    public function getCachedCompilePath()
    {
    	return $this->bootstrapCachePath().'/compiled.php';
    }

    /**
     * Get the path to the cached services.php file.
     *
     * @return string
     */
    public function getCachedServicesPath()
    {
    	return $this->bootstrapCachePath().'/services.php';
    }
}