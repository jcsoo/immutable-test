
export class Hello extends React.Component {
  render() {
    return (
      <div className="container">
        <h1>Hello {this.props.model.getName()}</h1>
      </div>
    );
  }
}
