package com.krang.backend.Controller;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.krang.backend.dto.AdminStatsResponse;
import com.krang.backend.dto.StatsRange;
import com.krang.backend.service.AdminStatsService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/admin/stats")
@RequiredArgsConstructor
public class AdminStatsController {

    private final AdminStatsService service;

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public AdminStatsResponse stats(@RequestParam(defaultValue = "today") StatsRange range) {
        return service.getStats(range);
    }
}
