import React, { Component } from 'react';
import { Card, Button } from 'semantic-ui-react';
import NotGivingEthT from '../ethereum/NotGivingEthT';
import Layout from '../components/Layout';
import { Link } from '../routes';
import TableExamplePadded from '../components/TableComponent';
import TabExampleVerticalTabular from '../components/TabExampleVerticalTabular';
import web3 from '../ethereum/web3';
// import NotGivingEthTWS from '../ethereum/NotGivingEthTWS';


class CampaignIndex extends Component {

  state = {
    result:''
  };

  componentDidMount() {

  //   NotGivingEthTWS.events.allEvents(({fromBlock: 0, toBlock: 'latest'}),(err, result) => {
  //   console.log("in log");
  //   console.log(JSON.stringify(result));
  //   console.log(err);
  //   this.setState({result:JSON.stringify(result)});
  // });

  }

  static async getInitialProps() {
    const accounts = await web3.eth.getAccounts();
    let black = await NotGivingEthT.methods.balanceOf(accounts[0]).call();
    let white = await NotGivingEthT.methods.balanceOfWhite(accounts[0]).call();
    console.log(black);
    console.log(white);
    //
    // all_events.watch(function(error, result) {
    //     if (!error) {
    //       console.log(result.args.one_of_my_parameters_of_the_event);
    //     }
    // });
    return { black,white };
  }




  render() {
    return(
      <Layout>
        <TabExampleVerticalTabular black={this.props.black}
          white={this.props.white}/>
      </Layout>
    );
  }


  //   return (
  //     <Layout>
  //       <div>
  //         <h3>Contributions</h3>

  //         <Link route="/campaigns/new">
  //           <a>
  //             <Button
  //               floated="right"
  //               content="Create Campaign"
  //               icon="add circle"
  //               primary
  //             />
  //           </a>
  //         </Link>

  //         {this.renderCampaigns()}
  //       </div>
  //     </Layout>
  //   );
  // }
}

export default CampaignIndex;
