<template>
  <a-card>
    <a-table v-model="refreshTable" :title="() => 'FlashDrives'"  :columns="flashdrives.columns" :data-source="flashdrives.data" :loading="flashdrives.loading">
      <template #edit="data">
        <a-button type="primary"  @click="readFiles(data.mountpoint)" style="margin-right: 10px">Browse</a-button>
      </template>
      <template #circle="data">
        <a-progress type="circle" :percent="parseInt(data.used_percentage.slice(0,-1))" :format="percent => `${percent} % ` +'(' +data.used + 'b)'" :width="80"  />
        </template>
      </a-table>
      <browseModal
      v-model="refreshModal"
      :path="path"
      :allFiles="allFiles"
      :isVisible="isVisible"
      :loaded="loaded"
      @readFiles="readFiles"
      @closeModal="closeModal"
      @modalRefres="modalRefresh"
      />
  </a-card>
</template>
<script>
// Ant design vue
import browseModal from './browseModal.vue'
export default {
  components: {
    browseModal
  },
  props: {
    readData: {
      type: Array,
      required: true
    }
  },
  watch: {
    readData: {
      deep: true,
      handler: function () {
        this.flashdrives.data = this.readData.map((v, i) => {
          v.key = i
          return v
        })
        if (Object.keys(this.readData).length === 0) {
          this.isVisible = false
        }
        this.flashdrives.loading = false
        this.tableRefresh()
      }
    }
  },
  data () {
    return {
      flashdrives: {
        columns: [
          { dataIndex: 'label', title: 'Label', key: 'label' },
          { dataIndex: 'dev', title: 'DEV', key: 'dev' },
          { dataIndex: 'mountpoint', title: 'MountPoint', key: 'mountpoint' },
          { dataIndex: 'available', title: 'Available', key: 'available' },
          { key: 'circle', title: 'Used', scopedSlots: { customRender: 'circle' } },
          { key: 'edit', width: 140, scopedSlots: { customRender: 'edit' } }
        ],
        loading: true
      },
      loaded: true,
      allFiles: [],
      isVisible: false,
      path: '',
      refreshModal: 0,
      refreshTable: 0
    }
  },
  methods: {
    tableRefresh () {
      this.refreshTable += 1
    },
    closeModal () {
      this.isVisible = false
    },
    openModal () {
      this.isVisible = true
    },
    modalRefresh () {
      this.refreshModal += 1
    },
    async readFiles (path) {
      this.loaded = false
      this.path = await this.formatPath(path)
      await this.$rpc.ubus('file', 'list', { path: this.path }).then(result => {
        this.allFiles = Object.values(result)
        this.loaded = true
        this.modalRefresh()
      })
      this.openModal()
    },
    formatPath (path) {
      if (path.includes('/..')) {
        path = path.substr(0, path.lastIndexOf('/'))
        path = path.substr(0, path.lastIndexOf('/'))
      }
      return path
    }
  }
}
</script>
