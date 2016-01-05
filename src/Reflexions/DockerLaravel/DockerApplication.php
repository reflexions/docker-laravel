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
    	return $this->storagePath ?: env('APP_STORAGE', $this->basePath.DIRECTORY_SEPARATOR.'storage');
    }
}