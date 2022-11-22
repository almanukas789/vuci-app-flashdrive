<template>
  <a-modal v-model="modalVisability" @cancel='closeModal()' :width="700" :title="'Path: ' +path" centered>
    <div class="scrollable-container">
      <div >
        <a-card :loading="!loaded" v-if="counter!==0" hoverable @click="goBack">
          <a-icon style="font-size: 225%;" type="folder" />
          <strong> /..</strong>
        </a-card>
        <div v-for="item in allFiles[0]" :key="item.id">
          <a-card :loading="!loaded" v-if="item.type === 'directory'"  hoverable>
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
          <a-card :loading="!loaded" v-if="item.type === 'file'">
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
      <a-button style="float:right;"  @click="showFolderModal">Create Folder</a-button>
      <a-upload :file-list="fileList" action="/upload" :data="{path: path +'/'+ fileName}" @change="onUpload" :beforeUpload="beforeUpload" >
        <a-button style="margin-right: 5px " type="primary"><a-icon type="upload" /> Upload</a-button>
      </a-upload>
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
      counter: 0,
      fileName: '',
      fileNameDisplay: '',
      fileList: [],
      size: 9999999999,
      multiple: true
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
    test () {
      console.log('asd')
    },
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
    },
    beforeUpload (file) {
      this.fileNameDisplay = file.name
      this.fileName = file.name
      var n = this.fileName.lastIndexOf('.')
      var counter = 1

      for (let i = 0; i < this.allFiles[0].length; i++) {
        if (this.allFiles[0][i].type === 'file') {
          if (this.allFiles[0][i].name.includes(file.name.split('.')[0] + '(')) {
            this.fileName = this.fileName.substring(0, n) + this.fileName.substring(n)
            break
          } else if (this.allFiles[0][i].name.includes(file.name.split('.')[0])) {
            for (let j = 0; j < this.allFiles[0].length; j++) {
              if (this.allFiles[0][j].name.includes(file.name.split('.')[0] + '(' + counter + ')')) {
                counter++
              }
            }
            this.fileName = this.fileName.substring(0, n) + '(' + counter + ')' + this.fileName.substring(n)
          }
        }
      }
    },
    onUpload (info) {
      const file = info.file
      const status = file.status

      if (file.size > this.size) {
        this.$message.error(`File size exceeds ${this.size}B limit.`)
        return
      }

      if (!this.multiple && info.fileList.length > 1) {
        this.$message.error('You can only upload one file.')
        return
      }

      this.fileList = info.fileList

      if (status === 'uploading' || status === 'removed') return

      if (status !== 'done') {
        return
      }

      this.$message.success(`File '${this.fileNameDisplay}' uploaded.`)
      this.fileList = []
      this.readFiles(this.path)
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
