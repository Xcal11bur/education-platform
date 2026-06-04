<template>
  <div class="page-card">
    <div class="page-header">
      <div>
        <h2 class="page-title">工作台</h2>
      </div>
    </div>

    <el-row :gutter="18">
      <el-col :xs="24" :md="8">
        <el-card shadow="hover">
          <template #header>联调进度</template>
        </el-card>
      </el-col>
      <el-col :xs="24" :md="8">
        <el-card shadow="hover">
          <template #header>后端基座</template>
        </el-card>
      </el-col>
      <el-col :xs="24" :md="8">
        <el-card shadow="hover">
          <template #header>下一步</template>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>
