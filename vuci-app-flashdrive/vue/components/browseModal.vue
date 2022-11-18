<template>
  <a-modal v-model="modalVisability" @cancel='closeModal()' :width="700" :title="'Path: ' +path" centered>
    <div class="scrollable-container">
      <div v-if="loaded">
        <a-card v-if="counter!==0"  hoverable @click="goBack">
          <a-icon style="font-size: 225%;" type="folder" />
          <strong> /..</strong>
        </a-card>
        <div v-for="item in allFiles[0]" :key="item.id">
          <a-card v-if="item.type === 'directory'" hoverable>
            <div class="main">
              <div style="width: 80%" @click="updatePath(item.name)" >
                <a-icon style="font-size: 225%;" type="folder-open" />
                {{item.name}}
              </div>
              <div style="margin-left: auto">
                <a-button size="small" @click="deleteAlert(item.name)" type="danger"><a-icon type="delete" /></a-button>
              </div>
            </div>
          </a-card>
          <a-card v-if="item.type === 'file'">
            <div class="main">
              <div style="width: 80%">
                <a-icon style="font-size: 225%;" type="file-text" />
                {{item.name}}
              </div>
              <div style="margin-left: auto">
                <a-button style="margin-right:5px" size="small"  @click="format(item.name)"><a-icon type="download" /></a-button>
                <a-button size="small" @click="deleteAlert(item.name)" type="danger"><a-icon type="delete" /></a-button>
              </div>
            </div>
          </a-card>
        </div>
      </div>
    </div>
    <template #footer>
      <div style="height:100px">
        <vuci-form uci-config="vuci">
          <vuci-named-section name="main" v-slot="{ s }" :card="false">
            <vuci-form-item-upload style="margin-left: auto;float:left;" :showUploadList="false" :size="99999999999" :multiple="true"  @change="uploadChange" name="main" :uci-section="s" :path="path + '/'"/>
          </vuci-named-section>
          <template #footer>
            <div>
              <a-button style="float:right;"  @click="showFolderModal">Create Folder</a-button>
            </div>
          </template>
        </vuci-form>
      </div>
    </template>
    <a-modal v-model="folderModal" :title="'Enter Folder Name'" @ok="createFolder" centered>
      <a-input v-model="folderName"></a-input>
    </a-modal>
    <div>
      <form ref="form" method="POST" action="/download">
        <input v-show="false" type="text" :value="path +'/'+ name"  name="path"/>
        <input v-show="false" type="text" :value="name" name="filename"/>
      </form>
    </div>
  </a-modal>
</template>
<script>
export default {
  props: {
    isVisible: Boolean,
    allFiles: Array,
    path: String,
    loaded: Boolean
  },
  data () {
    return {
      modalVisability: false,
      folderModal: false,
      folderName: '',
      downloadFileName: '',
      counter: 0
    }
  },
  watch: {
    isVisible: {
      deep: true,
      handler: function () {
        this.modalVisability = this.isVisible
      }
    }
  },
  methods: {
    format (name) {
      this.downloadFileName = name
      this.downloadPath = this.path
      this.download()
    },
    async download () {
      setTimeout(function () {
        this.$refs.form.submit()
      }.bind(this), 10)
    },
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
      this.$rpc.call('file', 'removeWildcard', { path: folderPath })
      this.readFiles(this.path)
      this.$message.success('Deleted')
      // ubus call file exec '{"command" : "rm", "params": ["-rf", "/mnt/sda1/testing"]}'
    },
    uploadChange () {
      this.readFiles(this.path)
    },
    createFolder () {
      var state = false
      for (let i = 0; i < this.allFiles[0].length; i++) {
        if (this.allFiles[0][i].name === (this.folderName) && this.folderName !== '') { state = true }
      }
      if (this.folderName === '') {
        this.$message.error('Please enter folder name')
      }
      if (state) {
        this.$message.error('This folder already exists')
      } else if (this.folderName !== '' && !state) {
        let folderPath = this.path
        folderPath += '/' + this.folderName
        this.closeFolderModal()
        this.$rpc.call('file', 'makeDirectory', { path: folderPath })
        this.$emit('modalRefresh')
        this.folderName = ''
        this.$message.success('Directory created!')
        this.readFiles(this.path)
      }
    },
    goBack () {
      let folderPath = this.path
      folderPath += '/..'
      this.decCounter()
      this.readFiles(folderPath)
    },
    readFiles (path) {
      this.$emit('readFiles', path)
    },
    updatePath (s) {
      let folderPath = this.path
      folderPath += '/' + s
      this.incCounter()
      this.readFiles(folderPath)
    },
    closeModal () {
      this.resetCounter()
      this.$emit('closeModal')
    },
    incCounter () {
      this.counter += 1
    },
    decCounter () {
      this.counter -= 1
    },
    resetCounter () {
      this.counter = 0
    }
  },
  computed: {
    name () {
      var s = this.downloadFileName
      var filename = s.replaceAll(' ', '%20')
      return filename
    }
  }
}
</script>
<style>
.main {
  display: flex;
  flex-wrap: wrap;
}
.scrollable-container {
  height: 600px;
  overflow-y: scroll;
}
</style>
