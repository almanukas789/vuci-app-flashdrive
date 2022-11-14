<template>
  <a-card>
    <a-table v-model="refreshTable" :title="() => 'FlashDrives'"  :columns="flashdrives.columns" :data-source="flashdrives.data" :loading="flashdrives.loading">
      <template #edit="text">
        <a-button type="primary"  @click="configPath(text.mountpoint)" style="margin-right: 10px">Browse</a-button>
      </template>
      <template #circle="text">
          <a-progress type="circle" :percent="parseInt(text.used_percentage.slice(0,-1))" :format="percent => `${percent} % ` +'(' +text.used + 'b)'" :width="80"  />
      </template>
    </a-table>
    <browseModal
      v-model="refreshModal"
      :path="path" :allFiles="allFiles"
      :isVisible="isVisible"
      :counter="counter"
      :startingPath="startingPath"
      @readFiles="readFiles"
      @resetCounter="resetCounter"
      @incCounter="incCounter"
      @decCounter="decCounter"
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
      allFiles: [{ files: [], folder: [] }],
      isVisible: false,
      path: '',
      startingPath: '',
      refreshModal: 0,
      refreshTable: 0,
      counter: 0
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
    convertStringToObject (object, response) {
      const allFiles = []
      let tempFolders = ''
      for (let i = 0; i < Object.keys(response[0]).length; i++) {
        if (object[i] === '\n') {
          allFiles.push(tempFolders)
          tempFolders = ''
        } else {
          tempFolders = tempFolders + object[i]
        }
      }
      this.filterFilesAndFolders(allFiles)
    },
    filterFilesAndFolders (allFiles) {
      this.allFiles = [{ files: [], folders: [] }]
      const resultFiles = allFiles.filter(word => word.includes('.'))
      const resultFolders = allFiles.filter(word => !word.includes('.'))
      this.allFiles[0].files.push(resultFiles)
      this.allFiles[0].folders.push(resultFolders)
      this.$spin(false)
      this.openModal()
      this.modalRefresh()
    },
    modalRefresh () {
      this.refreshModal += 1
    },
    incCounter () {
      this.counter += 1
    },
    decCounter () {
      this.counter -= 1
    },
    resetCounter () {
      this.counter = 0
      this.closeModal()
    },
    configPath (path) {
      this.startingPath = path
      this.readFiles(path)
    },
    readFiles (path) {
      this.flashdrives.data = this.readData
      this.closeModal(path)
      this.$spin(true)
      this.path = path
      this.$rpc.call('flashdrive', 'browse', { path: path }).then(r => {
        const text = JSON.parse(JSON.stringify(r[0]))
        this.convertStringToObject(text, r)
      })
    }
  }
}
</script>
