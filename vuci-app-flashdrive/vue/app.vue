<template>
  <div>
    <a-card v-if="data === undefined">
      <tableComponent :readData='data = []'/>
    </a-card>
    <div v-if="data !== undefined">
      <tableComponent :readData='data'/>
    </div>
    </div>
</template>
<script>
// Ant design vue
import tableComponent from './components/tableComponent.vue'
export default {
  components: {
    tableComponent
  },
  timers: {
    update: { time: 2000, autostart: true, repeat: true, immediate: true }
  },
  data () {
    return {
      data: undefined
    }
  },
  methods: {
    update () {
      this.$rpc.call('flashdrive', 'get').then(r => {
        const json = Object.values(JSON.parse(r))
        if (Object.keys(json).length === 0) {
          this.data = []
        } else {
          this.data = json
        }
      })
    }
  }
}
</script>
