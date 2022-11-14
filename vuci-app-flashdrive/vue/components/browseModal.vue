<template>
  <a-modal v-model="modalVisability" @cancel='closeModal()' :width="500" :title="'Browse'" centered>
    <a-card v-for="items in files[0].folders[0]" :key="items" hoverable >
        <div class="main">
          <div style="width: 80%" @click="updatePath(items)">
            <img src="./foldericon.png"/>
            {{items}}
          </div>
          <div style="margin-left: auto">
            <a-button  @click="deleteAlert(items)" type="danger">X</a-button>
           </div>
        </div>
    </a-card>
    <a-card v-for="items in files[0].files[0]" :key="items">
      <div class="main">
        <div style="width: 80%">
          <img  style="width:10%"  src="./fileicon.png"/>
            {{items}}
        </div>
        <div style="margin-left: auto">
          <a-button  @click="deleteAlert(items)" type="danger">X</a-button>
        </div>
      </div>
    </a-card>
    <template #footer>
      <vuci-form style="margin-left: auto;float:left" uci-config="test">
        <vuci-named-section name="enable" v-slot="{ s }" :card="false">
          <vuci-form-item-upload :showUploadList="false" :size="99999999999999" :multiple="true"  @change="uploadChange" name="enable" :uci-section="s" :path="path + '/'"></vuci-form-item-upload>
        </vuci-named-section>
        <template #footer><div></div></template>
      </vuci-form>
        <a-button type="" @click="showFolderModal">Create Folder</a-button>
        <a-button type="primary" @click="goBack">Back</a-button>
    </template>
    <a-modal v-model="folderModal" :title="'Enter Folder Name'" @ok="createFolder" centered>
    <a-input v-model="folderName"></a-input>
    </a-modal>
    </a-modal>
</template>
<script>
export default {
  props: {
    isVisible: Boolean,
    allFiles: Array,
    path: String,
    counter: Number,
    startingPath: String
  },
  data () {
    return {
      modalVisability: false,
      folderModal: false,
      folderName: '',
      files: [{ files: [], folders: [] }]
    }
  },
  watch: {
    isVisible: {
      deep: true,
      handler: function () {
        this.modalVisability = this.isVisible
      }
    },
    allFiles: {
      deep: true,
      handler: function () {
        this.files = this.allFiles
      }
    }
  },

  methods: {
    showFolderModal () {
      this.folderModal = true
    },
    closeFolderModal () {
      this.folderModal = false
    },
    deleteAlert (name) {
      this.$confirm({
        content: 'Are you sure you want to delete ' + name,
        onOk: () => {
          this.handleDelete(name)
        }
      })
    },
    handleDelete (item) {
      let folderPath = this.path
      folderPath += '/' + item
      this.$rpc.call('file', 'remove', { path: folderPath })
      this.$message.success('Deleted!')
      this.$emit('resetCounter')
      this.readFiles(this.startingPath)
    },
    uploadChange () {
      this.readFiles(this.path)
    },
    createFolder () {
      let folderPath = this.path
      folderPath += '/' + this.folderName
      this.closeFolderModal()
      this.$rpc.call('file', 'makeDirectory', { path: folderPath })
      this.$message.success('Folder created!')
      this.readFiles(this.startingPath)
    },
    goBack () {
      if (this.counter === 0) {
        this.$message.error('Denied!')
      } else {
        let folderPath = this.path
        folderPath += '/..'
        this.$emit('decCounter')
        this.readFiles(folderPath)
      }
    },
    readFiles (path) {
      this.$emit('readFiles', path)
    },
    updatePath (s) {
      let folderPath = this.path
      folderPath += '/' + s
      this.$emit('incCounter')
      this.readFiles(folderPath)
    },
    closeModal () {
      this.$emit('resetCounter')
    }
  }
}
</script>
<style>
.main {
  width: 100%;
  height: 100%;
  display: flex;
  flex-wrap: wrap;
}
</style>
