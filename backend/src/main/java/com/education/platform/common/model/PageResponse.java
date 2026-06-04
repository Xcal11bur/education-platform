package com.education.platform.common.model;

import java.util.Collections;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PageResponse<T> {

    private Long pageNum;
    private Long pageSize;
    private Long total;
    private List<T> list;

    public static <T> PageResponse<T> empty(long pageNum, long pageSize) {
        return PageResponse.<T>builder()
                .pageNum(pageNum)
                .pageSize(pageSize)
                .total(0L)
                .list(Collections.emptyList())
                .build();
    }
}
