<template>
  <div class="spreadsheet-tabs">

    <b-tabs end no-fade>
      <b-tab :title="sheetName" v-for="sheetName in workBook.SheetNames">
        <div id="example-container" class="wrapper">
          <worksheet :options="options"
                     :sheetAddress="sheetName"
                     :worksheet="workBook.Sheets[sheetName]"
                     :tenders="tenders"
                     :workbook="workbook"
                     />
        </div>
      </b-tab>
    </b-tabs>

  </div>
</template>

<script>
  import Worksheet from './Worksheet'

  import {
    recalculateFormulas,
    getSheetName,
    getRowColumnRef
  } from '../utils'

  import EventBus from '../EventBus'

  export default {
    components: {Worksheet},

    props: {
      workbook: {
        type: Object,
        required: true
      },
      options: {
        type: Object,
        default () {
          return {}
        }
      },
      tenders: {
        type: Array,
        required: true 
      }
    },

    data () {
      return {
        workBook: this.workbook
      }
    },

    mounted () {
      EventBus.$on('cell-change', this.updateWorkbook)
    },

    methods: {
      updateWorkbook ({cellAddress, value}) {
        console.log(cellAddress, value)
        let sheetName = getSheetName(cellAddress)
        let rowColumnRef = getRowColumnRef(cellAddress)
        this.$set(
          this.workBook.Sheets[sheetName][rowColumnRef],
          'v',
          value
        )

        this.$emit('save-rates', this.workBook)
      },
      numberToLetter(columnNumber) {
          let alphabets = ['F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N','O', 
                        'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z' ]
          if (columnNumber < 26) {
              return alphabets[columnNumber - 1];
          }
          else{
            var temp, letter = '';
            while (columnNumber > 0) {
                temp = (columnNumber - 1) % 26;
                letter = String.fromCharCode(temp + 65) + letter;
                columnNumber = (columnNumber - temp - 1) / 26;
            }
            return letter;
          }

        }
    }
  }
</script>

<style lang="scss">
  .spreadsheet-tabs {
    .nav-tabs {
      /*border-bottom: 1px solid #dee2e6;*/
      /*border-top: 1px solid #dee2e6;*/
      border: 1px solid #dee2e6;
      padding-left: 0.5rem;
      padding-right: 0.5rem;
      padding-bottom: 0.2rem;
    }

    .nav-tabs .nav-item {
      margin-top: -1px;
    }

    .nav-tabs .nav-link {
      border: 1px solid transparent;

      border-top-left-radius: initial;
      border-top-right-radius: initial;

      border-bottom-left-radius: 0.15rem;
      border-bottom-right-radius: 0.15rem;
    }

    .nav-tabs .nav-link:hover, .nav-tabs .nav-link:focus {
      border-color: #e9ecef #e9ecef #dee2e6;
    }

    .nav-tabs .nav-link.active,
    .nav-tabs .nav-item.show .nav-link {
      color: #495057;
      background-color: #fff;
      border-color: #fff #dee2e6 #dee2e6;
    }
  }
</style>