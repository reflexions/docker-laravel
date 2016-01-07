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
    	return env('LARAVEL_STORAGE_PATH', $this->storagePath ?: $this->basePath.DIRECTORY_SEPARATOR.'storage');
    }

    /**
     * Get the path to the configuration cache file.
     *
     * @return string
     */
    public function getCachedConfigPath()
    {
        return env('LARAVEL_BOOTSTRAP_CACHE_PATH'.'/config.php', $this->basePath().'/bootstrap/cache/config.php');
    }

    /**
     * Get the path to the routes cache file.
     *
     * @return string
     */
    public function getCachedRoutesPath()
    {
        return env('LARAVEL_BOOTSTRAP_CACHE_PATH'.'/routes.php', $this->basePath().'/bootstrap/cache/routes.php');
    }

    /**
     * Get the path to the cached "compiled.php" file.
     *
     * @return string
     */
    public function getCachedCompilePath()
    {
        return env('LARAVEL_BOOTSTRAP_CACHE_PATH'.'/compiled.php', $this->basePath().'/bootstrap/cache/compiled.php');
    }

    /**
     * Get the path to the cached services.php file.
     *
     * @return string
     */
    public function getCachedServicesPath()
    {
        return env('LARAVEL_BOOTSTRAP_CACHE_PATH'.'/services.php', $this->basePath().'/bootstrap/cache/services.php');
    }
}