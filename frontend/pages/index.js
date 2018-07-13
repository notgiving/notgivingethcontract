import React, { Component } from 'react';
import { Card, Button } from 'semantic-ui-react';
import MultiSigContract from '../ethereum/multisign';
import Layout from '../components/Layout';
import { Link } from '../routes';
import TableExamplePadded from '../components/TableComponent';
import TabExampleVerticalTabular from '../components/TabExampleVerticalTabular';

class CampaignIndex extends Component {
  static async getInitialProps() {
    let campaigns = await MultiSigContract.methods.listContributors().call();

    // campaigns = await Promise.all(
    //   campaigns.map((address) => {
    //       campaigns[address] = MultiSigContract.methods.getContributorAmount(address).call();
    //       return campaigns;
    //     })
    // );

    return { campaigns };
  }


  renderCampaigns = () => {
    console.log(this.props.campaigns);
    const items = this.props.campaigns.map(address => {
      return {
        header: address,
        description:'',
        fluid: true
      };
    });

    return <Card.Group items={items} />;
  }

  render() {
    return(
      <Layout>
        <TabExampleVerticalTabular/>
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
