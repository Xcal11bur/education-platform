package com.education.platform.infrastructure.storage;

import org.springframework.stereotype.Service;

@Service
public class LocalFileStorageService implements FileStorageService {

    @Override
    public String getProvider() {
        return "local-placeholder";
    }
}
